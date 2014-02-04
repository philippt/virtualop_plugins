def param_subversion(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_subversion_servers.map { |x| x["alias"] }
    },
    :autofill_context_key => 'subversion'
  })
  RHCP::CommandParam.new("subversion", "a stored subversion server config to work with", options)
end