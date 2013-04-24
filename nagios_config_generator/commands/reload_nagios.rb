description "reloads nagios after ensuring that the configuration is ok"

execute do |params|
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    nagios.ssh("command" => "/etc/init.d/nagios checkconfig")
    case nagios.linux_distribution.split("_").first
    when "centos", "sles"
      nagios.ssh("command" => "/etc/init.d/nagios reload")
    when "ubuntu"
      nagios.ssh("command" => "sudo /etc/init.d/nagios reload")
    end
  end
end
