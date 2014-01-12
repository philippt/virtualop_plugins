description "actually, this just stores the name and filenames for the keypair"

param! "alias", "a name for the keypair that should be stored"
param! "private_key_file"
param! "public_key_file"

execute do |params|
  current_command = Thread.current['broker'].get_command('store_keypair')
  @plugin.state[:drop_dir].write_params_to_file(current_command, params)
end