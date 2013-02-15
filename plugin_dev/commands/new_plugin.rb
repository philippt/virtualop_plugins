description "creates a new virtualop plugin skeleton"

param! "name", "the name for the new plugin"
param "path", "the path in which the new plugin should be created", :default_value => config_string('plugin_dir')

execute do |params|
  @op.with_machine('localhost') do |localhost|
    #plugin_path
    plugin_dir = config_string('plugin_dir') + '/' + params["name"]
    localhost.mkdir("dir_name" => plugin_dir)
    localhost.initialize_plugin("directory" => plugin_dir, "name" => params["name"])
  end
end