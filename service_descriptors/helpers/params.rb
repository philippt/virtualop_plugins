def param_canned_service(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|      
      @op.with_machine(request.get_param_value('descriptor_machine')) do |machine|
        machine.list_available_services("machine" => request.get_param_value('descriptor_machine')).map do |x|
          x["name"]
        end
      end
    end    
  })
  RHCP::CommandParam.new("service", "the service to work with", options)
end  