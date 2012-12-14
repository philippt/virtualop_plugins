def param_machine_group(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|
      @op.list_machine_groups.map { |x| x["name"] }
    end
  })
  RHCP::CommandParam.new("machine_group", "the machine group to work with", options)
end
