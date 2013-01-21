description "writes skeleton versions of all necessary vop metadata into a directory"

param :machine
param! "directory", "path to the directory to write into"
param! "name", "vop project name"

on_machine do |machine, params|
  dotvop_dir = "#{params["directory"]}/.vop"
  machine.mkdir("dir_name" => dotvop_dir)
  machine.initialize_plugin("directory" => dotvop_dir, "name" => params["name"])
  
  @op.add_service(params)
end
