description 'returns a list of all hetzner accounts configured in this virtualop instance'

display_type :table
add_columns [ :type, :alias, :user, :password, :ssh_port, :server_name_suffix ]

mark_as_read_only

contributes_to :list_hosting_accounts

execute do |params|
  drop_dir = @plugin.state[:hetzner_drop_dir]  
  #p @plugin.state
  drop_dir.read_local_dropdir.map do |account|
    account["type"] = "hetzner"
    account
  end
end
