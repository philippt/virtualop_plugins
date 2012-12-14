description "returns true if on the selected machine there's a unix service with the specified name and it's running"

param :machine
param! "service_name", "name of the service that should be checked"

on_machine do |machine, params|
  machine.list_unix_services().include?(params['service_name']) and machine.status_unix_service("name" => params['service_name'])
end  
