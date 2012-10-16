description "returns a list of services running on this machine with their current status"

param :machine

result_as :list_services
add_columns [ :status ]

on_machine do |machine, params|
  machine.list_services.map do |service|
    service["status"] = machine.status_service("service" => service["name"])
    service["is_running"] = service["status"] == "true"
    service
  end
end  
