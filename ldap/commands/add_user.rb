description "adds an user account on a LDAP server"

param :ldap_server

param! "username", "identifier for the new user"
param! "password", "password for the user"
param! "email", "email address of the user"

param! "first_name"
param! "last_name"


execute do |params|
  account = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  dn = [ "cn=#{params["username"]}", "ou=People", account["tree_base"] ].join(",")
  
  attr = {
    :objectclass => ["top", "person", "inetorgperson", "organizationalPerson"],    
    :cn => params["username"],
    
    :uid => params["username"],
    :mail => params["email"],
    :userPassword => (params.has_key?("password") ? params["password"] : 'change_me'),
  }
  attr.merge_from params, { :first_name => :givenname, :last_name => :sn }
  pp attr

  $logger.info "new user : #{dn}"
  @op.with_ldap("ldap_server" => params["ldap_server"]) do |ldap|
    ldap.add( :dn => dn, :attributes => attr )
      
    ldap_result = ldap.get_operation_result
    if ldap_result.code != 0 then
      raise Exception.new("could not add user : error code '#{ldap_result.code}': #{ldap_result.message}")
    end    
  end
end
