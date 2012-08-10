description "retrieves a bunch of log messages from rabbitmq and writes them into the database"

def do_sql(dbh, sql)
  #$logger.info(sql)
  dbh.query(sql)
end

execute do |params|
  known_existing_partitions = {}
  
  # the_log = @op.raw_log()
  # $logger.info "read #{the_log.size} entries"
  # 
  # the_log.each do |data|
  c = Carrot.new(:host => @op.plugin_by_name("rabbitmq_plugin").config_string('rabbitmq_hostname'))
  q = c.queue('raw_logging')

  result = []
  
  $logger.debug "count: #{q.message_count}"
  while msg = q.pop(:ack => true)
    #puts msg
    data = msg
    entry = JSON.parse(data)
    #p entry
    #puts "#{entry["phase"]} #{entry["request_id"]} #{entry["level"]} > #{current_stack} [#{mode}] #{request.command.name}"
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
    
    dbh = @plugin.state[:dbh]
        
    if entry["level"] == 1
      case phase
      when "start"      
        request = entry["request"]
            
        uid = nil
        if request.has_key?('context') and request['context'].has_key?('cookies') and request['context']['cookies'].has_key?('current_user')
          uid = request['context']['cookies']['current_user']
        end
            
        # the top-level request itself should be written into the unpartitioned index table
        # all the others go into the partitioned tables only
        params = []
        request["param_values"].each do |name, values|
          values.each do |value|
            value = "xxx" if /password/.match(name)
            params << "#{name}=#{value}"
          end
        end
        param_string = '(' + params.join(' ') + ')'
        
        do_sql(dbh, "INSERT INTO requests (request_id, command_name, param_string, uid, mode, start_ts)
                  VALUES ('#{request_id}', '#{request["command_name"]}', '#{dbh.escape_string(param_string)}', #{uid != nil ? "'#{uid}'" : 'NULL'}, '#{entry["mode"]}', '#{entry["start_ts"]}')")
      when "stop"
        escaped_response = dbh.escape_string(JSON.generate(entry["response"]))
        dbh.query("UPDATE requests SET response_code = '#{entry["response"]["status"]}', stop_ts = FROM_UNIXTIME(UNIX_TIMESTAMP(start_ts) + #{entry["duration"]}) " +
                  "WHERE request_id = '#{entry["request_id"]}'"
        )        
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
      
      escaped_request = dbh.escape_string(JSON.generate(request))
      do_sql(dbh, "INSERT INTO command_executions_#{partition} (request_id, command_name, param_string, mode, level, start_ts, json_request)
                  VALUES('#{request_id}', '#{request["command_name"]}', '#{param_string}', '#{entry["mode"]}', '#{entry["level"]}', '#{entry["start_ts"]}', '#{escaped_request}')
                ")
      
      execution_id = dbh.insert_id
      
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
        
        dbh.query(statement)
      end
    when "stop"
      response = entry["response"]
      escaped_response = dbh.escape_string(JSON.generate(response))
      statement = "UPDATE command_executions_#{partition} " +
                  # TODO stop_ts shouldn't be really now() here, should it?
                  "SET response_code = '#{response["status"]}', stop_ts = now(), " +
                     " error_message = '#{dbh.escape_string(response["error_text"])}', " +
                     " error_detail = '#{dbh.escape_string(response["error_detail"])}', " +
                     " json_response = '#{escaped_response}' " +
                  "WHERE request_id = '#{entry["request_id"]}' AND command_name = '#{entry["request"]["command_name"]}' AND response_code IS NULL"
      #puts statement                  
      dbh.query(statement)    
    end
    print "."
    q.ack
  end
  ""
end
