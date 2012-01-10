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
        [memcached_server]
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
    request.param_values.keys.sort.each do |key|
      sorted_param_values << request.param_values[key]
    end
    cache_key = request.command.name + '_' + Digest::SHA1.hexdigest(sorted_param_values.join('|'))

    should_read_from_cache = 
      (command.is_read_only) &&
      ( (not command.result_hints.has_key?(:cache)) || (command.result_hints[:cache]) ) &&
      ((request.context == nil) or (not request.context.cookies.has_key?('__caching.disable.read')))

    should_write_into_cache =
      (command.is_read_only) &&
      ( (not command.result_hints.has_key?(:cache)) || (command.result_hints[:cache]) ) &&
      ((request.context == nil) or (not request.context.cookies.has_key?('__caching.disable.write')))

    if should_read_from_cache
      cached_response_json = @cache.get(cache_key)
      if cached_response_json
        #cached_response = JSON.parse(cached_response_json)
        #cached_response = RHCP::Response.reconstruct_from_json(cached_response_json)
        cached_response = JSON.parse(cached_response_json)
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
        json_data = JSON.generate(response.as_json())        
        $logger.debug("storing data in cache for : #{cache_key} : #{json_data}")
        # TODO maybe we should use a lower expiration value for failed responses?
        @cache.set(cache_key, json_data, @expiry_seconds)
      end
    end

    response
  end

end
