description "creates a new virtualop plugin skeleton"

param! "name", "the name for the new plugin"

execute do |params|
  @op.with_machine('localhost') do |localhost|
    plugin_dir = config_string('plugin_dir') + '/' + params["name"]
    localhost.mkdir("dir_name" => plugin_dir)
    localhost.initialize_plugin("directory" => plugin_dir, "name" => params["name"])
  end
end