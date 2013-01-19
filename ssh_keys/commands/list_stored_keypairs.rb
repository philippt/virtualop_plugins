add_columns [ :alias, :private_key_file, :public_key_file ]

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir
end