description "adds a command object to the rabbit command queue for asynchronous processing"

param! "command_name", "name of the command that should be executed", :is_default_param => true

accept_extra_params

execute do |params|
  
  broker = Thread.current['broker']
  command = broker.get_command(params["command_name"])
  params["extra_params"] ||= {}
  context = broker.context.clone
  context.request_context_id = Time.now().to_i.to_s + '_' + command.name
  request = RHCP::Request.new(command, params["extra_params"], context)
  
  payload = JSON.generate({
   'request' => request.as_json()
  })
  
  c = Carrot.new(:host => config_string('rabbitmq_hostname'))
  q = c.queue('vop_commands')
  q.publish(payload)
  $logger.info "queued request #{request}"
  request
end
