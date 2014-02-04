require 'memcache'

class MemcachedBroker < RHCP::Broker

  def initialize(wrapped_broker, plugin)
    super("memcached_broker")
    @wrapped_broker = wrapped_broker
    @plugin = plugin

    # only enable if there's config for this plugin
    if @plugin.config.has_key?('server_name')
      memcached_server = @plugin.config['server_name']
      $logger.debug("connecting to memcached server '#{memcached_server}'")

      @cache = MemCache.new(
        [memcached_server],
        :timeout => 5
      )
      $logger.info("memcached plugin active (connected to '#{memcached_server}')")
    else
      raise Exception.new("missing configuration key 'server_name' for plugin #{@plugin.class.to_s}")
    end

    @expiry_seconds = 300
    if @plugin.config.has_key?('expiration_seconds')
      @expiry_seconds = @plugin.config['expiration_seconds']
    end
  end

  def get_command_list(context = RHCP::Context.new())
    @wrapped_broker.get_command_list(context)
  end

  def register_command(command)
    @wrapped_broker.register_command(command)
  end

  def clear
    @wrapped_broker.clear()
  end

  def execute(request)
    command = get_command(request.command.name, request.context)

    result = nil

    # construct the cache key out of the command name and all parameter values
    sorted_param_values = []
    request.param_values.keys.sort { |a,b| a.to_s <=> b.to_s }.each do |key|
      sorted_param_values << request.param_values[key]
    end
    cache_key = request.command.name + '_' + Digest::SHA1.hexdigest(sorted_param_values.join('|'))

    command_is_cacheable = (command.is_read_only) &&
      ( (not command.result_hints.has_key?(:cache)) || (command.result_hints[:cache]) )
      
    request_cookies = (request.context == nil ? {} : request.context.cookies) 

    should_read_from_cache = command_is_cacheable &&
      ((request.context == nil) or (not request.context.cookies.has_key?('__caching.disable.read')))

    should_write_into_cache =  command_is_cacheable &&
      ((request.context == nil) or (not request.context.cookies.has_key?('__caching.disable.write')))
      
    if should_read_from_cache
      if request_cookies.has_key?('__caching.bomb')
        depth = request_cookies['__caching.bomb'].to_i
        if depth > 0
          #puts "cache bomb prevents cache read for #{command.name}"
          Thread.current['broker'].context.cookies['__caching.bomb'] = depth - 1
          should_read_from_cache = false
        end
      end
    end

    if should_read_from_cache
      
      cached_response_json = @cache.get(cache_key)
      if cached_response_json
        
        base64_response = JSON.parse(cached_response_json)
        cached_response = RHCP::EncodingHelper.from_base64(base64_response)
        
        $logger.debug("got data from cache for #{cache_key}")
        cached_data = cached_response["data"]
        
        # TODO why don't we just throw back the response?
        response = RHCP::Response.new()          
        response.data = cached_data
        response.status = RHCP::Response::Status::OK
        
        # all context that has been sent with the request should be sent back
        response.context = request.context.cookies
        
        # also, we want to add all context that has been returned by the cached response
        if cached_response["context"] != nil then
          if response.context == nil then
            response.context = {}
          end
          $logger.debug("merging in context from cached response : #{cached_response["context"]}")
          cached_response["context"].each do |k,v|
            response["context"][k] = v
          end
        end
        
        response.created_at = cached_response["created_at"] 
        
        cached_response_is_usable = true
        if ((request.context != nil) and (request.context.cookies.has_key?('__caching.newer_than')))          
          if request.context.cookies['__caching.newer_than'].to_i > response.created_at.to_i
            $logger.debug("not using cached response because it's too old (we accept newer than #{request.context.cookies['__caching.newer_than'].to_i}, but it's from #{response.created_at.to_i})")
            cached_response_is_usable = false            
          end
        end
        
        if cached_response_is_usable
          result = cached_data
        end
      else

      end
    end

    if result == nil
      response = nil
      begin
        response = @wrapped_broker.execute(request)
      rescue Exception => e
        $logger.error("could not execute request : #{e.message}\n#{e.backtrace}")
      end

      # we might want to store the result in memcached nevertheless
      if should_write_into_cache # && (response.status == RHCP::Response::Status::OK)
        unless request.command.result_hints[:display_type] == "blob"
          base64_response = RHCP::EncodingHelper.to_base64(response.as_json())
          json_data = JSON.generate(base64_response)        
          $logger.debug("storing data in cache for : #{cache_key} : #{json_data}")
          # TODO maybe we should use a lower expiration value for failed responses?
          begin
            @cache.set(cache_key, json_data, @expiry_seconds)
          rescue => detail
            if /Value too large/ =~ detail.message
              $logger.warn("not caching result from #{request.command.name} cause it's too large for memcached")
            else
              raise
            end
          end
        else
          $logger.info "writing blob into file cache"  
        end
      end
    end

    response
  end

end
