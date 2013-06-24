description "performs a LDAP search"

param :ldap_server
param! "treebase", "the base of the tree that should be searched"
param! "search_filter", "the filter to search by"

execute do |params|
  filter = Net::LDAP::Filter.construct(params["search_filter"])
  treebase = params["treebase"]
  
  result = []
  @op.on_ldap("ldap_server" => params["ldap_server"], "what" => lambda { |ldap|
    ldap.search( :base => treebase, :filter => filter ) do |entry|
      #puts "found ldap entry"
      #pp entry

      h = {}
      entry.each do |attribute, values|
        h[attribute.to_s] = values
      end
      result << h
    end
    
    ldap_result = ldap.get_operation_result
    if ldap_result.code != 0 then
      raise Exception.new("could not execute ldap search : error code '#{ldap_result.code}': #{ldap_result.message}")
    end  
  })
  
  result
end
