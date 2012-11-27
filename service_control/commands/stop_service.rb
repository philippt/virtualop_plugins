description "stops a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "stop_command"
    machine.ssh_and_check_result("command" => service["stop_command"])
  else
    pids = machine.processes_for_service("service" => params["service"]).map { |x| x["pid"] }
    machine.kill_processes("pid" => pids)
  end
end  
