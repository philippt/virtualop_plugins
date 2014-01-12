param :hetzner_account
param! "ip", "the failover IP to switch", :lookup_method => lambda { |request| 
  @op.list_failover_ips("hetzner_account" => request.get_param_value("hetzner_account")).map { |x| x["ip"] } 
}
param! "target_ip", "the IP of the host to switch the IP to", :lookup_method => lambda { |request| 
  @op.list_hetzner_entries("hetzner_account" => request.get_param_value("hetzner_account")).map { |x| x["server_ip"] } 
}

execute do |params|
  hetzner_config = @op.list_hetzner_accounts.select do |account|
    account['alias'] == params['hetzner_account']
  end.first
  
  @op.with_machine("localhost") do |machine|
    json_data = machine.ssh("command" => "curl -s -u '#{hetzner_config['user']}:#{hetzner_config['password']}' https://robot-ws.your-server.de/failover/#{params["ip"]} -d active_server_ip=#{params["target_ip"]}")
  end
  
  @op.without_cache do
    @op.list_failover_ips("hetzner_account" => params["hetzner_account"])
  end
end
