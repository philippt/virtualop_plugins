description "waits for vop commands that are sent as JSON objects through a queue. commands are executed, they are not requeued on failure"

execute do |params|
  broker = Thread.current['broker']
  
  c = Carrot.new(:host => config_string('rabbitmq_hostname'))
  q = c.queue('vop_commands')

  result = []
  
  #rabbit_broker = RabbitmqBroker.new(broker, @op.plugin_by_name('rabbitmq_plugin'))
  #Thread.current['broker'] = rabbit_broker
  
  Thread.current['logging_enabled'] = 'true'
  #@op.enable_logging
  
  while (true) do
    $logger.debug "count: #{q.message_count}"
    #@op.listen_to_rabbit('queue' => 'vop_commands').each do |msg|
    while msg = q.pop(:ack => true)
      begin
        entry = JSON.parse(msg)
        r = entry["request"]
        puts "incoming #{r.pretty_inspect}"
        
        encoded_values = r["param_values"].dup
        r["param_values"] = RHCP::EncodingHelper.from_base64(encoded_values)
             
        command = broker.get_command(r["command_name"].split(".").last)
        
        #request = RHCP::Request.new(command, r["param_values"], broker.context.clone())
        p r["context"]
        context = RHCP::Context.from_hash(r["context"])
        puts "context : #{context}"
        request = RHCP::Request.new(command, r["param_values"], context)
        
        puts "request context : #{request.context}"
        puts "user : #{request.context.cookies['current_user']} (#{request.context.cookies['current_user_email']})"
        
        # TODO might want to test this with two users ;-) or multiple times even?
        
        @op.flush_cache()
        broker.context.cookies = {}
        @op.pre_flight_init()
        broker.context.cookies.merge! request.context.cookies
        
        puts ">>> executing : #{request}"
        response = broker.execute(request)
        puts "executed #{request.command.name} : #{response.status}"
        p response.data
      rescue Exception => msg
        $logger.error(msg)
      ensure
        @op.flush_buffer
        q.ack
      end
    end
    
    sleep 5
    print "."
  end
  
end


