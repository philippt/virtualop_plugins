description 'adds a new Hetzner account configuration'

param "alias", "the alias name for the new account", :mandatory => true
param "user", "the user name (for http authentication)", :mandatory => true
param "password", "the password for http authentication", :mandatory => true
param "ssh_user", "user for ssh connect to the hosts (default: root)"
param "ssh_port", "port for ssh connect to the hosts (default: 22)"
param "server_name_suffix", "suffix to complete the hetzner alias name to a full DNS name (experimental, madness)"

execute do |params|
  dropdir = @plugin.state[:hetzner_drop_dir]
  dropdir.write_params_to_file(Thread.current['command'], params)
  
  @op.cache_bomb
  @op.list_hetzner_accounts
end
