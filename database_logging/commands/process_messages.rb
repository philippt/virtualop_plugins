description "retrieves a bunch of log messages from rabbitmq and writes them into the database"

def do_sql(dbh, sql)
  #$logger.info(sql)
  print '.'
  dbh.query(sql)    
end

execute do |params|
  known_existing_partitions = {}
     
  unless plugin.state.has_key?(:carrot)
    host_name = @op.plugin_by_name("rabbitmq_plugin").config_string('rabbitmq_hostname')
    plugin.state[:carrot] = Carrot.new(:host => host_name)
    $logger.info "established connection to rabbitmq host #{host_name}"
  end 
  
  c = plugin.state[:carrot]
  q = c.queue('raw_logging')
  
  dbh = @plugin.state[:dbh]

  result = []
  
  #$logger.info "count: #{q.message_count}"
  #print "\n"
  while msg = q.pop(:ack => true)
    #puts msg
    data = msg
    #pp data
    
    entries = []
    begin
      entries = JSON.parse(data)
    rescue => detail
      $logger.error("could not parse JSON data : #{detail.message} - >>#{data}<<")
    end
    
    puts "\n***** #{entries.size}"
    entries.each do |entry|
      phase = entry["phase"]
      request_id = entry["request_id"]
      
      # let's assume the request_id contains a timestamp by which we can pick a partition
      matched = /^(\d+)_(.+)$/.match(request_id)
      $logger.warn("ignoring #{phase} message with request id #{request_id} - cannot parse timestamp") and next unless matched
      timestamp = matched.captures.first
      
      partition = Time.at(timestamp.to_i).strftime("%Y%m%d")
      $logger.debug "partition : #{partition}"
      
      @op.create_partition("partition_name" => partition) unless known_existing_partitions.has_key? partition
      known_existing_partitions[partition] = true
    
      original_request = entry["request"].dup if entry["request"]  
      if entry.has_key?("request")
        entry["request"]["param_values"] = RHCP::EncodingHelper.from_base64(entry["request"]["param_values"])
        #puts "re-encoded request"
      end
      
      original_response = entry["response"].dup if entry["response"]
      if entry.has_key?("response")
        entry["response"] = RHCP::EncodingHelper.from_base64(original_response)
        #puts "re-encoded response"
      end
      
      
          
      # the top-level request itself should be written into the unpartitioned index table
      # all the others go into the partitioned tables only
      if entry["level"] == 1
        case phase
        when "start"      
          request = entry["request"]
              
          uid = nil
          if request.has_key?('context') and request['context'].has_key?('cookies') and request['context']['cookies'].has_key?('current_user')
            uid = request['context']['cookies']['current_user']
          end
  
          params = []
          param_string = nil
          
          broker = Thread.current['broker']
          begin
            command = broker.get_command(request["command_name"].split("\.").last)
            
            command.params.each do |param|
              if request["param_values"].has_key? param.name
                blacklist = %w|extra_params what|
                next if blacklist.include? param.name
                values = request["param_values"][param.name]
                values.each do |value|
                  value = "xxx" if /password/.match(param.name)
                  params << "#{param.name}=#{value}"
                end
              end
            end
            param_string = '(' + params.join(' ') + ')'
          rescue => detail
            raise detail
          end
              
          if param_string == nil
            # plan b - construct param_string if the command cannot be loaded
            request["param_values"].each do |name, values|
              values.each do |value|
                value = "xxx" if /password/.match(name)
                params << "#{name}=#{value}"
              end
            end
            param_string = '(' + params.join(' ') + ')'
          end
          
          do_sql(dbh, "INSERT INTO requests_#{partition} (request_id, command_name, param_string, uid, mode, start_ts)
                    VALUES ('#{request_id}', '#{request["command_name"]}', '#{dbh.escape_string(param_string)}', #{uid != nil ? "'#{uid}'" : 'NULL'}, '#{entry["mode"]}', '#{entry["start_ts"]}')")
        when "stop"
          escaped_response = dbh.escape_string(JSON.generate(original_response))
          do_sql(dbh, "UPDATE requests_#{partition} SET response_code = '#{entry["response"]["status"]}', stop_ts = FROM_UNIXTIME(UNIX_TIMESTAMP(start_ts) + #{entry["duration"]}) " +
                       "WHERE request_id = '#{entry["request_id"]}'")        
        end
      end
      
      case phase
      when "start" 
        request = entry["request"]
        
        string_values = []
        request["param_values"].each do |name, values|
          values.each do |value|
            if value.class == Proc
              $logger.debug "not logging block parameter '#{name}'"
              next
            end
            value = "xxx" if /password/.match(name)
            string_values << "#{name}=#{value}" 
          end
        end
        param_string = dbh.escape_string('(' + string_values.join(' ') + ')')
        
        escaped_request = dbh.escape_string(JSON.generate(original_request))
        do_sql(dbh, "INSERT INTO command_executions_#{partition} (request_id, command_name, param_string, mode, level, start_ts, json_request)
                    VALUES('#{request_id}', '#{request["command_name"]}', '#{param_string}', '#{entry["mode"]}', '#{entry["level"]}', '#{entry["start_ts"]}', '#{escaped_request}')
                  ")
        
        execution_id = dbh.insert_id
        print "##{execution_id}"
        
        # this is an array of value arrays that will be used for constructing the sql statement
        all_values = []
        
        request["param_values"].each do |name, values|
          values.each do |value|
            if value.class == Proc
              $logger.debug "not logging block parameter '#{name}'"
              next
            end
            value = "xxx" if /password/.match(name)
            escaped_value = dbh.escape_string(value.to_s)
            all_values << [ "'#{request_id}'", execution_id, "'#{name}'", "'#{escaped_value}'" ]
          end
        end
        
        if all_values.size > 0
          statement = "INSERT INTO command_execution_params_#{partition} (request_id, execution_id, param_name, param_value) " +
            "VALUES "
          is_first_row = true
          all_values.each do |value_row|
            if is_first_row
              is_first_row = false
            else
              statement += ",\n"
            end
            statement += "(" + value_row.join(",") + ")"
          end
          #$logger.info statement
          
          do_sql(dbh, statement)
        end
      when "stop"
        response = entry["response"]
        escaped_response = dbh.escape_string(JSON.generate(original_response))
        statement = "UPDATE command_executions_#{partition} " +
                    # TODO stop_ts shouldn't be really now() here, should it?
                    "SET response_code = '#{response["status"]}', stop_ts = now(), " +
                       " error_message = '#{dbh.escape_string(response["error_text"])}', " +
                       " error_detail = '#{dbh.escape_string(response["error_detail"])}', " +
                       " json_response = '#{escaped_response}' " +
                    "WHERE request_id = '#{entry["request_id"]}' AND command_name = '#{entry["request"]["command_name"]}' AND response_code IS NULL"
        do_sql(dbh, statement)    
      end
      #print "."
      print "\n"
      $stdout.flush()
    end
    dbh.commit()
    q.ack
  end
  
  # TODO might want to close at some point, though (there's no close, but something called Carrot.stop)
  #c.close()
  
  ""
end
