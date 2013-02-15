param :hetzner_account

mark_as_read_only

add_columns [ "ip", "ip_lookup", "server_ip", "server_ip_lookup", "active_server_ip", "active_server_ip_lookup", "netmask" ]

execute do |params|
  result = []
  
  hetzner_config = @op.list_hetzner_accounts.select do |account|
    account['alias'] == params['hetzner_account']
  end.first
  
  @op.with_machine("localhost") do |machine|
    yaml_data = machine.ssh_and_check_result("command" => "curl -s -u '#{hetzner_config['user']}:#{hetzner_config['password']}' https://robot-ws.your-server.de/failover.yaml")
  
    data = YAML.load(yaml_data)
    data.each do |row|
      if row.has_key? "failover"
        h = row["failover"]
        h.each do |k,v|
          if matched = /(.+_)?ip/.match(k)
            h["#{k}_lookup"] = @op.dig("query" => v).first["hostname"]
          end
        end
        result << h
      end
    end
  end
  
  result
end