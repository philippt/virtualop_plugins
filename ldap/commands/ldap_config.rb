param :ldap_server

display_type :hash

execute do |params|
  result = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  uri = URI::parse result['connection_string']
  result["host_name"] = uri.host
  
  result
end
