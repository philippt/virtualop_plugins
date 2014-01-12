description "performs something on an LDAP server"

param :ldap_server
param! "block", "something to do while something else is locked"

execute do |params|
  ldap = @op.get_ldap_connection("ldap_server" => params["ldap_server"])
  begin
    params["block"].call(ldap)
  ensure
    # TODO release connection
  end
end
