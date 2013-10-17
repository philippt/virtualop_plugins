description "returns the directory on the specified machine in which configuration for installed services should be stored"

param :machine

mark_as_read_only

on_machine do |machine, params|
  (machine.config != nil && machine.config.has_key?("service_control") && machine.config["service_control"].has_key?("service_config_dir")) ?
    machine.config["service_control"]["service_config_dir"] :
    config_string('service_config_dir')  
end  
