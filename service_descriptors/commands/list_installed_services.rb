description "lists the services that have been installed on this machine"

param :machine

display_type :list

mark_as_read_only

on_machine do |machine, params|
  if machine.file_exists("file_name" => config_string('service_config_dir'))
    machine.list_files("directory" => config_string('service_config_dir'))
  else
    []
  end
end
