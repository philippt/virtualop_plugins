description "returns user groups configured in a LDAP server"

param :ldap_server

add_columns [ :cn, :description ]

execute do |params|
  account = @op.list_ldap_servers.select { |x| x["alias"] == params["ldap_server"] }.first
  
  result = []
  @op.ldap_search(
    "ldap_server" => params["ldap_server"], 
    "treebase" => "ou=Groups,#{account["tree_base"]}", 
    "search_filter" => "objectclass=groupOfUniqueNames"
  ).each do |entry|
    h = {}
    entry.each do |k,v|
      h[k.to_s] = v.first.strip
    end
    result << h
  end
  result
end
