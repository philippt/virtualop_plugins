description "adds a service check configuration to nagios"

param :machine
param! "service_description", "name/description of the new service" 
param! "check_command", "the check command that should be executed"
param "service_template", "the server template to use", :default_value => config_string('service_template').join(',')

on_machine do |machine, params|
  @op.with_machine(plugin.config_param('nagios_machine_name')) do |nagios|
    generated = read_local_template(:service, binding())
    nagios.append_to_file("file_name" => machine.nagios_file_name, "content" => generated)  
  end
end
