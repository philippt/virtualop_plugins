description "deletes the nagios configuration for a machine"

param :machine

on_machine do |machine, params|
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    if nagios.file_exists("file_name" => nagios_file_name(machine))
      nagios.rm("file_name" => nagios_file_name(machine))
    end
  end
end
