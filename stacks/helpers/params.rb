def param_stack(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { @op.list_stacks.map { |x| x["name"] } },
    :allows_multiple_values => true
  })
  RHCP::CommandParam.new("stack", "the stack that should be evaluated", options)
end
