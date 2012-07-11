description "starts a service"

param :machine
param :service

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key? "run_command"
    machine.mkdir("dir_name" => service["service_root"] + '/log')
    
    # TODO this probably does not work for services without service_root
    bin_path = service["service_root"] + '/.vop/bin'
    script_path = bin_path + '/start_' + service["name"] + '.sh'
    
    machine.mkdir("dir_name" => bin_path)
    process_local_template(:start_background_job, machine, script_path, binding())
    machine.chmod("file_name" => script_path, "permissions" => "+x")
    
    machine.ssh_and_check_result("command" => script_path)
  elsif service.has_key? "start_command"
    machine.ssh_and_check_result("command" => service["start_command"])
  else
    raise "don't know how to start service #{service["name"]}"
  end
end  
