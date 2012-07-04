class RabbitmqBroker < RHCP::LoggingBroker
  
  def initialize(broker, plugin)
    super(broker)
    @op = plugin.op
    @plugin = plugin
  end
  
  def get_blacklisted_commands
    commands = super()
    # commands << "log_ssh_start"
    # commands << "log_ssh_stop"
    commands << "pre_flight_init"
    commands << "create_partition"
    # commands << "get_ssh_connection"
    # commands << "default_user"
    # commands << "default_port"
    
    commands << "hello_rabbit"
    commands << "listen_to_rabbit"
    commands << "ssh_options_for_machine"
    commands << "ssh_extended"
    commands << "text_log"
    commands << "raw_log"
    commands << "show_plugin_config"
    commands << "execute_as_hudson_job"
    #commands << "process_messages"
    #commands << "listen_and_execute"
    commands
  end
  
  def get_graylisted_commands
    result = super()
    result << "listen_and_execute"
    result
  end
  
  def log_request_start(request_id, level, mode, current_stack, request, start_ts)
    request_id = Thread.current[var_name("request_id")]
    
    return if /^database_logging\./.match(request.command.full_name)
    
    param_values = []
    request.param_values.each do |k,v|
      next if v.class == Proc.class
      param_values << "#{k} => #{v}"
    end
    
    @op.hello_rabbit(
      "queue" => "text_logging",
      "message" => "#{request_id} #{level} > #{current_stack} [#{mode}] #{request.command.name} (#{param_values.join(", ")})"
    )
    
    #  Die Timestamps wenn es geht im ISO8601 format bidde
    j = JSON.generate({
      :request_id => request_id,
      :phase => 'start',
      :level => level,
      :mode => mode,
      :current_stack => current_stack,
      :request => request.as_json(),
      :start_ts => start_ts.iso8601()
    })
    @op.hello_rabbit("queue" => "raw_logging", "message" => j)
  end
  
  def log_request_stop(request_id, level, mode, current_stack, request, response, duration)
    request_id = Thread.current[var_name("request_id")]
    @op.hello_rabbit("queue" => "text_logging", "message" => "#{request_id} #{level} < #{current_stack} #{response != nil ? response.status : '-'} #{duration}s")
    
    j = JSON.generate({
      :request_id => request_id,
      :phase => 'stop',
      :level => level,
      :mode => mode,
      :current_stack => current_stack,
      :request => request.as_json(),
      :response => response.as_json(),
      :duration => duration
    })
    @op.hello_rabbit("queue" => "raw_logging", "message" => j)
  end
  
  
end