def param_ldap_server(options = {})
  merge_options_with_defaults(options, {
    :autofill_context_key => 'ldap_server'
  })
  param_ldap_server_without_context(options)
end

def param_ldap_server_without_context(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_ldap_servers.map { |x| x["alias"] }
    }
  })
  RHCP::CommandParam.new("ldap_server", "alias of an LDAP server to use", options)
end 