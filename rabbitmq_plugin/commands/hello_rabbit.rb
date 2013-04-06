param! "queue", "the destination queue"
param "message", "the message that should be sent", :default_value => 'hello world'

execute do |params|
  begin
    # TODO [health] add disconnect in shutdown hook
    host_name = config_string('rabbitmq_hostname', 'localhost')
    unless plugin.state.has_key?(:carrot)
      plugin.state[:carrot] = {}
    end
    
    unless plugin.state[:carrot].has_key?(host_name)
      plugin.state[:carrot][host_name] = Carrot.new(:host => host_name)
      $logger.info "opening new rabbitmq connection to #{host_name}"             
    end
    c = plugin.state[:carrot][host_name]
    
    q = c.queue(params["queue"])  
    q.publish(params["message"])
  rescue => detail
    $logger.error("could not send rabbitmq message '#{params["message"]}' : #{detail.message}")
  end    
end