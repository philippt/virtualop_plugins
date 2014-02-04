param :ldap_server_without_context

execute do |params|
  @plugin.state[:drop_dir].delete_local_dropdir_entry params['ldap_server']
  
  @op.without_cache do
    @op.list_ldap_servers
  end
end
