description "starts a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "run_command"
    # TODO this writes a new start script every time the service is started
    (script_path, output) = machine.start_background_process("service" => service["name"])
  elsif service.has_key? "start_command"
    start_command = service["start_command"]
    if service.has_key?("service_root")
      start_command = "cd #{service["service_root"]} && #{start_command}"
    end
    machine.ssh("command" => start_command, "request_pty" => "true")
  elsif service.has_key? "windows_service"
    machine.start_windows_service("service" => service["windows_service"])
  else
    raise "don't know how to start service #{service["name"]}"
  end
end  
