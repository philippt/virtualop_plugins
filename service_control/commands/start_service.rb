description "starts a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "run_command"
    service["service_root"] ||= '.'
    
    redirect_log_file = service.has_key?("redirect_log") ? service["redirect_log"] : "#{service["service_root"]}/log/#{service["name"]}.log"
    machine.mkdir("dir_name" => File.dirname(redirect_log_file))
        
    (script_path, output) = machine.start_background_process(
      "directory" => service["service_root"], 
      "command_line" => service["run_command"], 
      "log_file" => redirect_log_file,
      "name_hint" => service["name"]
    )
    
    if service.has_key? "cron"
      # TODO actually, we shouldn't do this at every start
      machine.add_crontab_entry("data" => read_local_template(:crontab, binding()))
    end        
  elsif service.has_key? "start_command"
    machine.ssh_and_check_result("command" => service["start_command"])
  else
    raise "don't know how to start service #{service["name"]}"
  end
end  
