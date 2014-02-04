param! "queue", "the destination queue"
param "message", "the message that should be sent", :default_value => 'hello world'

execute do |params|
  host_name = config_string('rabbitmq_hostname', 'localhost')
  begin
    # TODO [health] add disconnect in shutdown hook
    unless plugin.state.has_key?(:carrot)
      plugin.state[:carrot] = {}
    end
    
    unless plugin.state[:carrot].has_key?(host_name)
      plugin.state[:carrot][host_name] = Carrot.new(:host => host_name)
    end
    c = plugin.state[:carrot][host_name]
    
    q = c.queue(params["queue"])  
    q.publish(params["message"])
  rescue => detail
    msg_size = params["message"].size()
    $logger.error("could not send rabbitmq message '#{params["message"]}' (size: #{msg_size} bytes) : #{detail.message}")
    # remove the connection from the pool just in case
    plugin.state[:carrot].delete(host_name)
  end    
end
