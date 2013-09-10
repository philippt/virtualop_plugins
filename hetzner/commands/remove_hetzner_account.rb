param :hetzner_account

#result_as :list_hetzner_accounts

execute do |params|
  @plugin.state[:hetzner_drop_dir].delete_local_dropdir_entry params["hetzner_account"]
  
  @op.cache_bomb
  @op.list_hetzner_accounts
end
