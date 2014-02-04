description "calls the status check command of a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  # TODO actually, we should execute multiple checks
  result = "unknown"  
  if service.has_key? "status_command"
    status = machine.ssh_extended("command" => service["status_command"])
    result = status["result_code"] == 0
  elsif service.has_key? "process_regex"
    result = machine.processes_like("string" => service["process_regex"]).size > 0
  elsif service.has_key? "run_command"
    result = machine.processes_like("string" => service["run_command"]).size > 0
  elsif service.has_key? "unix_service"
    result = machine.status_unix_service("name" => machine.unix_service_name("unix_service" => service["unix_service"]))
  elsif service.has_key? "windows_service"
    result = machine.status_windows_service("service" => service["windows_service"])
  end
  
  # TODO think about boolean values in general
  result.to_s
end  
