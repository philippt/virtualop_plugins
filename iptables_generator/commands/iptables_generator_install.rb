param :machine

on_machine do |machine, params|  
  process_local_template(:logrotate, machine, "/etc/logrotate.d/iptables", binding())
  machine.ssh_and_check_result("command" => 'echo "kern.=debug                                               /var/log/iptables" >> /etc/rsyslog.conf')
  machine.restart_unix_service("name" => "rsyslog")
end
