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
      result = machine.win_find_files("path" => config_dir, "type" => "f")
    end
  else
    config_dir = machine.config_dir
    if machine.file_exists("file_name" => config_dir)
      result = machine.find("path" => config_dir, "type" => "f").map do |x|
        x[config_dir.length+1..x.length-1].chomp.strip
      end
    end
  end
  result
end
