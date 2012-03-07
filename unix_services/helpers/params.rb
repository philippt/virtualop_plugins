def param_unix_service(description = 'the service to work with')
  RHCP::CommandParam.new("name", description,
    {
      :mandatory => true,
      :lookup_method => lambda { |request|
        @op.with_machine(request.get_param_value('machine')) do |host|
          host.list_unix_services#.map do |service|
          #  service["name"]
          #end
        end

      }
    }
  )
end