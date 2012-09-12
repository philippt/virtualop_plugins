description "performs something on an LDAP server"

param :ldap_server
param! "what", "the block to execute"

execute do |params|
  ldap = @op.get_ldap_connection("ldap_server" => params["ldap_server"])
      
  block = params["what"]
  block.call(ldap)
end
