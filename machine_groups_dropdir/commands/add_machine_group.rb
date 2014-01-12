description "adds a new user-defined machine group"

param! "name", "machine-readable alias"
param! "parent", "name of the parent group"
param! "members", "a list of machines that should form the group", :allows_multiple_values => true

execute do |params|
  params["path"] = '/' + (params["parent"] == "root" ? '' : params["parent"] + '/') + params["name"]
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
  
  @op.cache_bomb
  @op.list_machine_groups
end  