description "reloads nagios after ensuring that the configuration is ok"

execute do |params|
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    nagios.ssh_and_check_result("command" => "/etc/init.d/nagios checkconfig")
    nagios.ssh_and_check_result("command" => "/etc/init.d/nagios reload")
  end
end
