description "calls the status check command of a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  result = "unknown"
  if service.has_key? "status_command"
    status = machine.ssh_extended("command" => service["status_command"])
    result = (status["result_code"] == 0).to_s
  end
  
  result
end  
