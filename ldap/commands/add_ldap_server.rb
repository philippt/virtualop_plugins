description "adds configuration for a new LDAP server connection"

param! "alias", "an alias name for the LDAP connection"
param! "connection_string", "LDAP connection string to the target system"
param "bind_user", "the name of the user to bind with"
param "bind_password", "password corresponding to bind_user"
param! "tree_base", "the default tree base to use"

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
end

