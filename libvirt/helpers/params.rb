def param_vm(description="name of the VM against which the command should be executed")
    RHCP::CommandParam.new("name", description,
      {
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
      }
    )
  end