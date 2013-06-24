description 'lists all hosts in an hetzner account'

param :hetzner_account

mark_as_read_only

display_type :table
add_columns [ :server_name, :server_ip, :dc, :product, :status, :traffic, :flatrate, :throttled, :cancelled, :paid_until ]

#contributes_to :list_machines

execute do |params|
  result = []
  
  hetzner_config = @op.list_hetzner_accounts.select do |account|
    account['alias'] == params['hetzner_account']
  end.first
  
  @op.with_machine("localhost") do |machine|
    yaml_data = machine.ssh("command" => "curl -s -u '#{hetzner_config['user']}:#{hetzner_config['password']}' https://robot-ws.your-server.de/server.yaml")
  
    data = YAML.load(yaml_data)
    data.each do |data_row|
      if data_row.has_key?('server')
        the_data = data_row['server']
        extra_data = {
          'ssh_port' => hetzner_config.has_key?('ssh_port') ? hetzner_config['ssh_port'] : 22,
          'ssh_user' => hetzner_config.has_key?('ssh_user') ? hetzner_config['ssh_user'] : 'root',
          'name' => (the_data.has_key?('server_name') and the_data['server_name'] != "" ? the_data['server_name'] : the_data['server_ip']) + "." + hetzner_config['alias'],
          #'ssh_name' => the_data['server_name'] + config_string('server_name_suffix', ''),
          'ssh_name' => the_data['server_ip'],
          'type' => 'host',
          'environment' => hetzner_config.has_key?('environment') ? hetzner_config['environment'] : 'lab'
        }
        the_data.merge! extra_data
        
        result << the_data
      end
    end
  end
   
  result
end