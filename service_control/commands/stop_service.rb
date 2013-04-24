description "stops a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "stop_command"
    stop_command = service["stop_command"]
    if service.has_key?("service_root")
      stop_command = "cd #{service["service_root"]} && #{stop_command}"
    end
    machine.ssh("command" => stop_command)
  elsif service.has_key? "windows_service"
    machine.stop_windows_service("service" => service["windows_service"])
  else
    pids = machine.processes_for_service("service" => params["service"]).map { |x| x["pid"] }
    machine.kill_processes("pid" => pids)
  end
end  
