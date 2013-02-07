def param_vm(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { |request|
      result = []
      @op.with_machine(request.get_param_value("machine")) do |machine|
        machine.list_vms().map do |vm|
          result << vm["name"]
        end
      end
      result
    }
  })
  
  RHCP::CommandParam.new("name", "name of the VM against which the command should be executed", options)
end