description "returns a list of services running on this machine with their current status"

param :machine

param "all"

result_as :list_services
add_columns [ :status ]

#include_for_crawling

#mark_as_read_only

on_machine do |machine, params|
  machine.list_services.select do |service|
    service["is_startable"] || params["all"]
  end.map do |service|
    service["status"] = "unknown" 
    begin
      service["status"] = machine.status_service("service" => service["full_name"])
    rescue => detail
      $logger.warn("could not get service status for service '#{service["full_name"]}' : #{detail.message}")
    end    
    service["is_running"] = service["status"] == "true"
    service
  end
end  
