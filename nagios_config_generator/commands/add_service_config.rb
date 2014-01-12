description "adds a service check configuration to nagios"

param :machine
param! "service_description", "name/description of the new service" 
param! "check_command", "the check command that should be executed"
param "service_template", "the server template to use", :default_value => config_string('service_template').join(',')
param "disable_notifications", "if set to 'true', notifications will be disabled", :lookup_method => lambda { %w|true false| }, :default_value => config_string('disable_generated_notifications', 'true')

on_machine do |machine, params|
  notifications_enabled = params['disable_notifications'] == 'false'
  
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    generated = read_local_template(:service, binding())
    nagios.append_to_file("file_name" => machine.nagios_file_name, "content" => generated)  
  end
end
