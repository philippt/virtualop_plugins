def param_unix_service(description, options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { |request|
      @op.with_machine(request.get_param_value('machine')) do |host|
        host.list_unix_services#.map do |service|
        #  service["name"]
        #end
      end

    }
  })
  RHCP::CommandParam.new("name", "a unix service to work with", options)
end
