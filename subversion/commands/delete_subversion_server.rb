description "deletes the configuration for a subversion server"

param :subversion

add_columns [ "alias", "url", "user" ]

execute do |params|
  @plugin.state[:drop_dir].delete_local_dropdir_entry params["subversion"]
  
  @op.without_cache do
    @op.list_subversion_servers
  end
end

