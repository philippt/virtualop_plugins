description "schedule a host to have services checks run again right now"

param :machine
param "service", "name of the service that should be checked", :lookup_method => lambda { |request|
  @op.list_nagios_checks("machine" => request.get_param_value("machine")).map { |x| x["name"] }
}

on_machine do |machine, params|
  result = []
  
  # TODO copied from nagios_config_generator.nagios_file_name
  machine_name = machine.name == "localhost" ? machine.hostname : machine.name
  
  with_nagios do |site|
    site.schedule_service_check(machine_name, params["service"])
  end
  result
end
