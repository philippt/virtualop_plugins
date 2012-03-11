param :machine
param! "service_full_name"

on_machine do |machine, params|
  dir = params["service_full_name"]
  plugin_file_name = dir + '/.vop/' + dir.split('/').last + '.plugin'
  if machine.file_exists("file_name" => plugin_file_name)
    machine.load_plugin("plugin_file_name" => plugin_file_name)      
  end
end   