description "calls plugin_list and writes the resulting JSON data into a file on a machine"#

params_as :list_all_plugins
param :machine
param! "file_name", "path to the file that should be written"

on_machine do |machine, params|
  stuff = @op.plugin_list
  machine.write_file("target_filename" => params["file_name"], "content" => stuff)
  machine.allow_access_for_apache("file_name" => params["file_name"])
end
