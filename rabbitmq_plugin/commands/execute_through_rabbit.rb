description "adds a command object to the rabbit command queue for asynchronous processing"

param! "command_name", "name of the command that should be executed", :is_default_param => true
#param "param_hash", "hash with parameter values", :default_value => {}
#param "extra_params", "a hash of extra parameters for the service install command", :default_value => {}

accept_extra_params

execute do |params|
  
  broker = Thread.current['broker']
  command = broker.get_command(params["command_name"])
  request = RHCP::Request.new(command, params["extra_params"], broker.context)
  #p request.as_json()
  
  payload = JSON.generate({
   'request' => request.as_json()
  })
  
  c = Carrot.new(:host => config_string('rabbitmq_hostname'))
  q = c.queue('vop_commands')
  q.publish(payload)
  $logger.info "queued request #{request}"
end
