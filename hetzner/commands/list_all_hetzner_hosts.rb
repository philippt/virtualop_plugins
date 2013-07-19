description 'returns a list of all hosts in all configured hetzner accounts'

mark_as_read_only

display_type :table
add_columns [ :name, :type, :env, :account, :server_name, :server_ip, :dc, :product, :status, :traffic, :flatrate, :throttled, :cancelled, :paid_until ]

#contributes_to :list_machines
contributes_to :find_hosts

execute do |params|
  result = []
  @op.list_hetzner_accounts.each do |account|    
    hosts_in_account = @op.list_hetzner_entries('hetzner_account' => account['alias'])
    hosts_in_account.each do |host|
      host['account'] = account['alias']
    end
    result += hosts_in_account
  end
  result
end
