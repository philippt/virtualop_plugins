def param_current_user(options = {})
  merge_options_with_defaults(options, {
    :autofill_context_key => 'current_user'#,
    #:default_value => ENV['USER'] # TODO another curious manifestation of madness, it seems *chuckle*   
  })
  RHCP::CommandParam.new("current_user", "the name of the user that triggered this command", options)
end