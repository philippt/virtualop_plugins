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
  elsif service.has_key? "stop_block"
    fresh_details = nil
    @op.without_cache do
      fresh_details = machine.service_details("service" => params["service"])
    end
    begin
      stop_block = fresh_details["stop_block"]
      stop_block.call(machine, service, params)
    rescue => detail
      raise "problem in stop block for service #{params["service"]} on #{params["machine"]} : #{detail.message}"
    end
  elsif service.has_key? "unix_service"
    machine.stop_unix_service("name" => machine.unix_service_name("unix_service" => service["unix_service"]))
  elsif service.has_key? "windows_service"
    machine.stop_windows_service("service" => service["windows_service"])
  else
    pids = machine.processes_for_service("service" => params["service"]).map { |x| x["pid"] }
    machine.kill_processes("pid" => pids) if pids and pids.size > 0
  end
end  
