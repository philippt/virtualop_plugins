description "disables nagios host notifications. does not include notifications for services on this host"

param :machine
param "nagios_machine", "the alias of the nagios machine to work with"

on_machine do |machine, params|
  @op.with_machine(config_string("nagios_machine")) do |nagios_machine|
    nagios_host_name = machine.name
    nagios_command = "now=`date +%s` printf \"[%lu] DISABLE_HOST_NOTIFICATIONS;#{nagios_host_name}\n\" $now > #{config_string('nagios_command_pipe')}"
    nagios_machine.ssh("command" => nagios_command)
  end
end
