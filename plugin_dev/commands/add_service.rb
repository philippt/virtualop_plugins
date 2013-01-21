description "adds vop configuration for a service inside a project"

param :machine
param! "directory", "path to the project"
param! "name", "name for the service"

on_machine do |machine, params|
  service_name = params["name"]
  
  dotvop_dir = params["directory"] + '/.vop'
  service_dir = dotvop_dir + '/services'
  
  machine.mkdir("dir_name" => service_dir)
  machine.write_file("target_filename" => "#{service_dir}/#{service_name}.rb", "content" => "# service #{service_name}")
  
  install_command_file = [ dotvop_dir, '/commands/', "#{service_name}_install.rb" ].join("/")
  process_local_template(:install_command, machine, install_command_file, binding())
end
