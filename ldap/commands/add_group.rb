description "adds a group (for people) on a LDAP server"

param :ldap_server

param! 'name'
param! 'description'

execute do |params|
  account = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  # {"dn"=>["cn=Accounting Managers,ou=Groups,dc=ldap,dc=dev,dc=virtualop,dc=org"], 
  #  "objectclass"=>["top", "groupOfUniqueNames"], "cn"=>["Accounting Managers"], "ou"=>["groups"], 
  #  "description"=>["People who can manage accounting entries"], "uniquemember"=>["cn=manager"]}
  
  dn = [ "cn=#{params["name"]}", "ou=Groups", account["tree_base"] ].join(",")
  
  attr = {
    :objectclass => %w|top groupOfUniqueNames|,    
    :cn => params['name'],
    :ou => ['groups'],
  }
  attr.merge_from params, { :first_name => :givenname, :last_name => :sn }
  pp attr

  $logger.info "new group : #{dn}"
  @op.with_ldap("ldap_server" => params["ldap_server"]) do |ldap|
    ldap.add( :dn => dn, :attributes => attr )
      
    ldap_result = ldap.get_operation_result
    if ldap_result.code != 0 then
      raise Exception.new("could not add group '#{params['name']}' : error code '#{ldap_result.code}': #{ldap_result.message}")
    end    
  end
end
