
class RabbitmqBroker < RHCP::LoggingBroker
  
  MAX_BUFFER_SIZE = 25
  
  @@buffer = []
  
  @@buffer_lock = Mutex.new
  
  @@flusher = Thread.new do
    while (true) do
      flush_buffer
      sleep 10
    end
  end
  
  def self.flush_buffer(op)
    @@buffer_lock.synchronize {
      $logger.info "sending rabbitmq buffer : #{@@buffer.size}" 
      op.hello_rabbit("queue" => "raw_logging", "message" => JSON.generate(@@buffer))
      @@buffer = []
    }
  end
  
  def change_all_strings(thing, &block)
    result = nil
    #puts "#{thing.class}"
    case thing.class.to_s
    when "Array" then
      result = []
      thing.each do |x|
        result << change_all_strings(x, &block)
      end
    when "Hash" then
      result = {}
      thing.each do |k,v|
        result[k] = change_all_strings(v, &block)
      end
    when "String" then
      result = block.call(thing)  
    end
    result
  end
  
  def change_encoding(thing)
    change_all_strings(thing) do |x|
      x.force_encoding('ISO-8859-1').encode('UTF-8')
    end
  end
  
  def remove_invalid(thing)
    change_all_strings(thing) do |x|
      x.encode('UTF-8', :invalid => :replace)
    end
  end
  
  def to_rabbit(payload)
    #change_all_strings(payload) do |x|
    #  x.length > 20 ? x[0..20] : x
    #end
    
    json_payload = nil
    begin
      json_payload = JSON.generate([payload])
    rescue Encoding::UndefinedConversionError 
      json_payload = JSON.generate(change_encoding([payload]))
    rescue ArgumentError => arrrgh
      json_payload = JSON.generate(remove_invalid([payload]))
    rescue => detail
      $logger.error("could not generate JSON representation : #{detail.class.to_s} : #{detail.message}, payload : #{payload.pretty_inspect}")
    end
    
    #z = Zlib::Deflate.new()
    #just_payload = JSON.parse(json_payload)
    #zipped_payload = change_all_strings(just_payload) do |x|
    #  z.deflate x
    #end
    #json_payload = JSON.generate(zipped_payload)
    
    if json_payload
      if @use_buffer
        @@buffer << payload
        if @@buffer.size >= MAX_BUFFER_SIZE
          self.class.flush_buffer(@op)
        end
      else           
        @op.hello_rabbit("queue" => "raw_logging", "message" => json_payload)
      end
    end
  end
  
  def initialize(broker, plugin)
    super(broker)
    @op = plugin.op
    @plugin = plugin
    
    @use_buffer = (plugin.config_string('buffer_enabled', false).to_s == 'true')
  end
  
  def get_blacklisted_commands
    commands = super()
    #commands << "log_ssh_start"
    #commands << "log_ssh_stop"
    commands << "pre_flight_init"
    commands << "create_partition"
    # commands << "get_ssh_connection"
    # commands << "default_user"
    # commands << "default_port"
    
    commands << "flush_buffer"
    commands << "hello_rabbit"
    commands << "listen_to_rabbit"
    commands << "ssh_options_for_machine"
    commands << "ssh_extended"
    
    commands << "text_log"
    commands << "raw_log"
    commands << "show_plugin_config"
    commands << "execute_as_hudson_job"
    commands << "execute_through_rabbit"
    
    commands << "select_datacenter"
    #commands << "process_messages"
    commands << "listen_and_execute"
    
    commands += %w|enrich_machine_list machine_by_name list_machines on_machine|
    
    commands += %w|ssh_and_check_result ssh_extended get_ssh_connection|
    
    commands
  end
  
  def get_graylisted_commands
    result = super()
    result << "listen_and_execute"
    result
  end
  
  def broker_enabled?(request)
    @plugin.config_string('broker_enabled', 'false') == 'true' &&
    (Thread.current['logging_enabled'] == 'true' ||
     request.context.cookies['logging_enabled'] == 'true'
    )
  end
  
  def log_request_start(request_id, level, mode, current_stack, request, start_ts)
    request_id = Thread.current[var_name("request_id")]
    
    return unless broker_enabled? request
    
    return if /^database_logging\./.match(request.command.full_name)
    
    param_values = []
    request.param_values.each do |k,v|
      next if v.class == Proc.class
      param_values << "#{k} => #{v}"
    end
    
    # TODO reactivate text log?
    #@op.hello_rabbit(
    #  "queue" => "text_logging",
    #  "message" => "#{request_id} #{level} > #{current_stack} [#{mode}] #{request.command.name} (#{param_values.join(", ")})"
    #)
    
    #  Die Timestamps wenn es geht im ISO8601 format bidde
    j = {
      :request_id => request_id,
      :phase => 'start',
      :level => level,
      :mode => mode,
      :current_stack => current_stack,
      :request => request.as_json(),
      :start_ts => start_ts.utc.iso8601()
    }
    
    to_rabbit(j)
  end
  
  def log_request_stop(request_id, level, mode, current_stack, request, response, duration)
    return unless broker_enabled? request
    
    request_id = Thread.current[var_name("request_id")]
    #@op.hello_rabbit("queue" => "text_logging", "message" => "#{request_id} #{level} < #{current_stack} #{response != nil ? response.status : '-'} #{duration}s")
    
    j = {
      :request_id => request_id,
      :phase => 'stop',
      :level => level,
      :mode => mode,
      :current_stack => current_stack,
      :request => request.as_json(),
      :response => response.as_json(),
      :duration => duration
    }
    to_rabbit(j)
  end
  
  
end
