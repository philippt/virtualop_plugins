description 'configures a new data repo'

param! "alias", "human- and machine-readable name for the account"
param! "url", "http url to the data repo"
param! :machine

add_columns [ "url" ]

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
    
  @op.without_cache do
    @op.list_data_repos 
  end
end
