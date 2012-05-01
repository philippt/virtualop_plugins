param! "queue", "the destination queue"
param "message", "the message that should be sent", :default_value => 'hello world'

execute do |params|
  begin
    c = Carrot.new(:host => config_string('rabbitmq_hostname', 'localhost'))
    q = c.queue(params["queue"])  
    q.publish(params["message"])
  rescue => detail
    $logger.error("could not send rabbitmq message '#{params["message"]}'", detail)
  end    
end