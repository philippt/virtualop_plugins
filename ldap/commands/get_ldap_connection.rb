description "establishes a new LDAP connection or returns one from the pool"

param! "ldap_server", "alias of an LDAP server to use", :lookup_method => lambda {
  @op.list_ldap_servers.map { |x| x["alias"] }
}

execute do |params|
  ldap_config = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  connection_string = ldap_config["connection_string"]
  should_not_use_cache = (params.has_key?('no_cache') and (params['no_cache'] == "true"))
  
  pool = @plugin.state[:connection_pool]
  if ((not pool.has_key?(connection_string)) or (should_not_use_cache))
    uri = URI::parse(connection_string)
    
    $logger.debug("connecting against ldap server '#{uri.host}' on port '#{uri.port}'")
    ldap = uri.scheme == "ldaps" ? MyLDAP.new({:encryption => :simple_tls}) : MyLDAP.new()
    ldap.host = uri.host
    ldap.port = uri.port
            
    if params.has_key?("user")
      ldap.auth params["user"], params["password"]
      raise Exception.new("could not connect against ldap - invalid credentials for user '#{params["user"]}'") unless ldap.bind
    elsif ldap_config.has_key?("bind_user") and ldap_config.has_key?("bind_password")
      ldap.auth ldap_config["bind_user"], ldap_config["bind_password"]
      raise Exception.new("could not connect against ldap - invalid credentials for user '#{ldap_config["bind_user"]}'") unless ldap.bind
    else
      $logger.debug("found no authentication information configured for ldap alias '#{params["ldap_host"]}' - attempting anonymous connection")
    end
            
    pool[connection_string] = ldap
  end
  ldap = pool[connection_string]

  # TODO protect against stale connections
    
  ldap
  
  #plugin.state[:connection_pool]
    
end

