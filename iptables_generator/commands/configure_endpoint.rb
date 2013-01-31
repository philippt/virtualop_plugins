param :machine
param! "protocol", "", :lookup_method => lambda { %w|tcp udp| }
param! "source_machine"
param! "service"
param! "port"

on_machine do |machine, params|
  port = params["port"]
  protocol = params["protocol"]
  
  params["service"] = params["service"] + '.' + params["port"].to_s
  
  %w|port protocol|.each { |x| params.delete(x) }
  
  source_ip = @op.ipaddress("machine" => params["source_machine"])
  
  @op.add_prerouting_include params.merge({ 
    "content" => "iptables -t nat -A PREROUTING -p #{protocol} -d $IP_HOST --dport #{port}  -j DNAT --to-destination #{source_ip}:#{port}" 
  })
  
  @op.add_input_include params.merge({
    "content" => "iptables -A INPUT -d $IP_HOST -p #{protocol} --dport #{port} -m state --state NEW -j ACCEPT"
  })
  
  @op.add_forward_include params.merge({
    "content" => "iptables -A FORWARD -d #{source_ip} -p #{protocol} --dport #{port} -m state --state NEW -j ACCEPT"
  })
    
  machine.generate_and_execute_iptables_script()
end
