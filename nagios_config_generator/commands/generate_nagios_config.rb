description "generates nagios configuration for a machine"

param :machine

on_machine do |machine, params|
  target_file = machine.nagios_file_name

  local_partitions = machine.disk_space.select do |row|
    /^\/dev/.match(row["filesystem"])
  end

  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    process_local_template(:machine, nagios, target_file, binding())  
    nagios.chmod("file_name" => target_file, "permissions" => "644")
  end
end
