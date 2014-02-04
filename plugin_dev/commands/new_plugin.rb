description "creates a new virtualop plugin skeleton"

param! "name", "the name for the new plugin"
param "path", "the path in which the new plugin should be created", :default_value => config_string('plugin_dir')

param "extra_folder", "name of extra folders that should be created inside the .vop dir", :allows_multiple_values => true

execute do |params|
  @op.with_machine('localhost') do |localhost|
    plugin_path = params["path"]
    plugin_dir = plugin_path + '/' + params["name"]
    localhost.mkdir("dir_name" => plugin_dir)
    localhost.initialize_plugin({"directory" => plugin_dir}.merge_from(params, :name, :extra_folder))
  end
end