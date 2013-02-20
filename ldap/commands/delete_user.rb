description "adds an user account on a LDAP server"

param :ldap_server

param! "username", "identifier for the new user"

execute do |params|
  account = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
 
  dn = [ "cn=#{params["username"]}", "ou=People", account["tree_base"] ].join(",")
  @op.with_ldap("ldap_server" => params["ldap_server"]) do |ldap|
    ldap.delete( :dn => dn )
    
    ldap_result = ldap.get_operation_result
    if ldap_result.code != 0 then
      raise Exception.new("could not delete user '#{dn}' in ldap : error code #{ldap_result.code}: '#{ldap_result.message}'")
    end  
  end
end