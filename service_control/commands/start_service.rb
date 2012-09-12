description "starts a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "run_command"
    (script_path, output) = machine.start_background_process("service" => service["name"])
  elsif service.has_key? "start_command"
    machine.ssh_and_check_result("command" => service["start_command"])
  else
    raise "don't know how to start service #{service["name"]}"
  end
end  
