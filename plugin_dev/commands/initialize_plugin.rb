description "generates the base file structure for a vop plugin"

param :machine
param! "directory", "path to the directory to write into (e.g. the .vop dir of a project)"
param! "name", "the name for the new plugin"

param "extra_folder", "name of extra folders that should be created inside the .vop dir", :allows_multiple_values => true

on_machine do |machine, params|
  plugin_dir = params["directory"]
  
  (%w|commands helpers templates| + (params["extra_folder"] || [])).each do |x|      
    machine.mkdir("dir_name" => plugin_dir + '/' + x)
  end
  
  plugin_file_name = "#{plugin_dir}/#{params["name"]}.plugin"
  process_local_template(:plugin_file, machine, plugin_file_name, binding())
end

