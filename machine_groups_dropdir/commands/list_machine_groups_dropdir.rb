description "reads machine groups from the filesystem" 

contributes_to :list_machine_groups
result_as :list_machine_groups

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir
end