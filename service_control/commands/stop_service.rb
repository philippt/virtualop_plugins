description "stops a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "stop_command"
    machine.ssh_and_check_result("command" => service["stop_command"])
  elsif service.has_key? "run_command"
    machine.kill_processes_like("string" => service["run_command"])
  end
end  
