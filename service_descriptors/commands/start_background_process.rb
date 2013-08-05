description "uses 'nohup' and the '&' operator to start a process that keeps running in the background"

param :machine
param :service

on_machine do |machine, params|
  script_path = machine.write_background_start_script(params)
    
  output = machine.ssh("command" => "#{script_path} && sleep 3")
  [ script_path, output ]
end  
