description "enables nagios notifications for this host. does not include service checks."

param :machine
param "nagios_machine", "the alias of the nagios machine to work with"

on_machine do |machine, params|
  @op.with_machine(config_string("nagios_machine")) do |nagios_machine|
    nagios_host_name = machine.name.strip
    nagios_command = "now=`date +%s` printf \"[%lu] ENABLE_HOST_NOTIFICATIONS;#{nagios_host_name}\n\" $now > #{config_string('nagios_command_pipe')}"
    nagios_machine.ssh("command" => nagios_command)
  end
end
