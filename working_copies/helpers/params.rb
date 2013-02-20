def param_working_copy(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|
      @op.with_machine(request.get_param_value("machine")) do |machine|
        machine.list_working_copies.map do |w|
          w["name"]
        end
      end
      
    end
  })
  RHCP::CommandParam.new("working_copy", "the working copy that should be used", options) 
end