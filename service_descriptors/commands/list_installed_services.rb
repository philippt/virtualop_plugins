description "lists the services that have been installed on this machine"

param :machine

display_type :list

mark_as_read_only

#include_for_crawling

on_machine do |machine, params|
  result = []
  if machine.machine_detail["os"] == "windows"
    config_dir = '.vop/services'
    if machine.win_file_exists("file_name" => config_dir)
      result = machine.win_list_files("directory" => config_dir)
    end
  else
    if machine.file_exists("file_name" => machine.config_dir)
      result = machine.list_files("directory" => machine.config_dir)
    end
  end
  result
end
