description "adds a service check configuration to nagios"

param :machine
param! "service_description", "name/description of the new service" 
param! "check_command", "the check command that should be executed"

on_machine do |machine, params|
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    generated = read_local_template(:service, binding())
    
    old_content = nagios.read_file("file_name" => machine.nagios_file_name)
    nagios.append_to_file("file_name" => machine.nagios_file_name, "content" => generated)  
  end
end
