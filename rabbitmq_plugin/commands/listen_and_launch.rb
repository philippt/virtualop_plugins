description "listens for new vop commands and spawns them as separate vop processes"

execute do |params|
  broker = Thread.current['broker']
  
  c = Carrot.new(:host => config_string('rabbitmq_hostname'))
  q = c.queue('vop_commands')

  result = []
  
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
        
        p r["context"]
        context = RHCP::Context.from_hash(r["context"])
        puts "context : #{context}"
        request = RHCP::Request.new(command, r["param_values"], context)
        
        puts "request context : #{request.context}"
        puts "user : #{request.context.cookies['current_user']} (#{request.context.cookies['current_user_email']})"
        
        #command = "nohup vop"
        command_line = config_string('launch_command')
        
        if request.context.cookies['current_user']
          command_line += " -u #{request.context.cookies['current_user']}"
        end
        
        if request.context.request_context_id
          command_line += " -r #{request.context.request_context_id}"
        end
        
        command_line += ' -o ' + request.context.cookies.map do |k,v|
          values = v.is_a?(Array) ? v : [ v ]
          values.map { |value| "#{k}=#{value}" }
        end.join(',')
        
        command_string = "#{r["command_name"].split(".").last}"
        r["param_values"].each do |k,v|
          next if k == 'extra_params'
          values = v.is_a?(Array) ? v : [ v ]
          values.each do |value|
            command_string += " #{k}=#{value}"
          end
        end
        
        if r["param_values"].has_key?("extra_params")
          extra_params = r["param_values"]["extra_params"]
          extra_params = extra_params.first if extra_params.is_a?(Array)
          extra_params.each do |k,v|
            values = v.is_a?(Array) ? v : [ v ]
            values.each do |value|
              command_string += " #{k}=#{value}"
            end
          end
        end
        
        command_line += " -fl --execute='#{command_string}' &"      
        
        puts "+++\nlaunching\n+++\n#{command_line}\n+++"
        system command_line
        puts "launched."
        
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
