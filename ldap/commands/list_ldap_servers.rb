description "returns a list of available LDAP servers to connect against"

add_columns [ :alias, :connection_string, :bind_user ]

#mark_as_read_only

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir
end
