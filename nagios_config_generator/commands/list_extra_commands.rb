description "returns the extra nagios commands defined on the configured nagios machine"

param :machine, "a nagios machine to work with", 
  :default_value => config_string('nagios_machine_name'), :mandatory => false

display_type :list

on_machine do |nagios, params|
  dir_name = config_string("config_root") + '/extra_commands'
  nagios.file_exists("file_name" => dir_name) ? nagios.list_files("directory" => dir_name) : []
end    


