param :data_repo
param! "alias", "human- and machine-readable name for the account"

execute do |params|
  @plugin.state[:drop_dir].delete_local_dropdir_entry params["alias"]
  
  @op.without_cache do
    @op.list_data_repos
  end
end
