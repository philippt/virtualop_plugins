def param_runlevel(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { %w|stopped maintenance running| }
  })
  RHCP::CommandParam.new("runlevel", "the new runlevel that should be reached", options)
end