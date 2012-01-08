def param_canned_service(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_available_services.map do |x|
        x["name"]
      end
    end    
  })
  RHCP::CommandParam.new("service", "the service to work with", options)
end  