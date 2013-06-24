description "searches for a computer account in the LDAP directory"

param :ldap_server
param! "computername", "the computer name to search for"

add_columns [ :cn ]

execute do |params|
  ldap_config = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  found = @op.ldap_search(
    "ldap_server" => params["ldap_server"],
    "treebase" => ldap_config["tree_base"],
    "search_filter" => "(&(objectclass=computer)(cn=#{params["computername"]}))"
  )
  #puts "found something"
  #pp found
  #raise "did not find computer with name #{params["computername"]}" if found.size == 0
  #raise "sanity check failed - found more than one computer with name #{params["computername"]}" if found.size > 1
  
  #entry = found.first
  #entry
  found
end
