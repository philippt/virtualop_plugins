description "adds configuration for a known subversion server"

param! "alias"
param! "url"
param "user"
param "password"

add_columns [ "alias", "url", "user" ]

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
  
  @op.without_cache do
    @op.list_subversion_servers
  end
end
  
