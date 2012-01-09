description "lists the services that have been installed on this machine"

param :machine

display_type :list

mark_as_read_only

on_machine do |machine, params|
  machine.list_files("directory" => service_config_dir)
end
