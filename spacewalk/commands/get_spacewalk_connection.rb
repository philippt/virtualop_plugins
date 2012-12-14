description "returns a connection to the spacewalk server"

param :spacewalk_host

execute do |params|
  connection_pool = plugin.state[:connection_pool]
  
  connection_string = params["spacewalk_host"]
  unless connection_pool.has_key?(connection_string)
    $logger.debug "establishing new spacewalk connection..."      
    
    # TODO add a disconnect once we got shutdown hooks
    connection = SpacewalkConnection.new(connection_string)
    connection.connect()
    connection_pool[connection_string] = connection
  end
  connection = connection_pool[connection_string]

  # protect against stale connections
  begin
    $logger.debug "testing spacewalk connection #{connection}..."
    machine_list = connection.list_all_machines
    # sometimes, the call works, but we get an empty list
    if machine_list.size == 0 then
      $logger.warn "got empty machine list from spacewalk...suspecting that the connection is snafu'ed. reconnecting..."
      connection.connect(true)
    end
  rescue Exception => e
    if /end of file reached/.match(e.message) then
      $logger.warn "stale connection detected - trying to establish new connection..."
      connection.connect(true)
    else
      $logger.warn "got an error : #{e.message} - trying to reconnect"
      connection.connect(true)
    end
  end

  # TODO could make sense to re-test again here

  $logger.debug "got a working connection."
  connection
end
