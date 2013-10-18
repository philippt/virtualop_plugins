param :machine

result_as :list_services

mark_as_read_only

on_machine do |machine, params|
  machine.list_services.select do |service|
    details = machine.service_details("service" => service["full_name"])
    details["databases"].size > 0 or details["local_files"].size > 0 
  end
end
