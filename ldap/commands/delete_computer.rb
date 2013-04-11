description "searches for a computer account by name and deletes it"

param :ldap_server
param! "computername", "the computer name to search for"

#add_columns [ :cn, :dn ]
display_type :hash

execute do |params|
  found = @op.search_computer(params)
  
  raise "did not find computer with name #{params["computername"]}" if found.size == 0
  raise "sanity check failed - found more than one computer with name #{params["computername"]}" if found.size > 1
  
  moriturus = found.first["dn"].first
  $logger.info "deleting LDAP entry on #{params["ldap_server"]} using DN #{moriturus}"
  
  unless params["just_kidding"]
    @op.on_ldap({"ldap_server" => params["ldap_server"], "what" => lambda { |ldap|
      ldap.delete( :dn => moriturus)
      
      ldap_result = ldap.get_operation_result
      if ldap_result.code != 0 then
        raise Exception.new("could not execute ldap search : error code '#{ldap_result.code}': #{ldap_result.message}")
      end
    }})
  end
  
  moriturus  
end
