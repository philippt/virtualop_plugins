require 'carrot'

param! "queue", "the queue which should be checked for messages"

execute do |params|
  #q = Carrot.queue('tasks', :durable => true)    # => undefined method `message_count' for #<Carrot::AMQP::Protocol::Channel::Close:0x7ffc214c8220>
  c = Carrot.new(:host => config_string('rabbitmq_hostname', 'localhost'))
  q = c.queue(params["queue"])

  result = []
  
  $logger.debug "count: #{q.message_count}"
  while msg = q.pop(:ack => true)
   #puts msg
   #p msg
   result << msg
   q.ack
  end
  c.stop

  result
end