description "generates a script that is written onto the target machine - if called, the generated script will run a command as background process"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  service["service_root"] ||= '.'
    
  redirect_log_file = service.has_key?("redirect_log") ? service["redirect_log"] : "#{service["service_root"]}/log/#{service["name"]}.log"
  machine.mkdir("dir_name" => File.dirname(redirect_log_file))
      
  #script_dir = '/var/lib/virtualop/bin'
  script_dir = "#{machine.home}/.vop/bin"
  machine.mkdir("dir_name" => script_dir)
  script_path = script_dir + '/vop_start_background_process_' + service["name"] + Time.now().to_i.to_s + '.sh' 
  
  spawn = service.has_key?("run_command.spawn") ? service["run_command.spawn"].to_i : 1  
  
  process_local_template(:start_background_process, machine, script_path, binding())
  machine.chmod("file_name" => script_path, "permissions" => "+x")
  
  script_path    
end  
