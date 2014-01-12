add_columns [ :name, :dropdir_filename ]

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir
end