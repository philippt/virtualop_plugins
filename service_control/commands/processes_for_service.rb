param :machine
param :service

result_as :processes

on_machine do |machine, params|
  service = machine.service_details("service" => params["service"])
  
  process_regex = service.has_key?("process_regex") ?
    service["process_regex"] : 
    service["run_command"]
  
  machine.processes_like("string" => process_regex)
end  
