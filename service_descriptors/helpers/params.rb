def param_descriptor_machine(options = {})
  merge_options_with_defaults(options, {
    :lookup_method => lambda do
      @op.list_machines.map do |x|
        x["name"]
      end
    end,
    :default_value => 'localhost'
  })
  RHCP::CommandParam.new("descriptor_machine", "alternative location to read the descriptor from", options) 
end

def param_canned_service(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|      
      @op.with_machine('localhost') do |localhost|
        $logger.info "lookup for canned service - on localhost : #{localhost.name}"
        localhost.list_available_services().map do |x|
          x["full_name"]
        end
      end
    end    
  })
  RHCP::CommandParam.new("service", "the service to work with", options)
end  

def param_service_full_name(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|      
      @op.with_machine(request.get_param_value("machine")) do |machine|        
        localhost.list_services().map do |x|
          x["full_name"]
        end
      end
    end    
  })
  RHCP::CommandParam.new("service", "the service to work with", options)
end

def param_github_project(options = {})
  merge_options_with_defaults(options, {
  })
  RHCP::CommandParam.new("github_project", "the github project to install (e.g. philippt/virtualop)", options)
end