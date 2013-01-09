description "lists the services that have been installed on this machine"

param :machine

display_type :list

mark_as_read_only

#include_for_crawling

on_machine do |machine, params|
  if machine.file_exists("file_name" => machine.config_dir)
    machine.list_files("directory" => machine.config_dir)
  else
    []
  end
end
