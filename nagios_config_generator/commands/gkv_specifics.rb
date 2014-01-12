#TODO contributes_to :additional_nagios_config
contributes_to :additional_nagios_config

param :machine

with_contributions do |result, params|
  @op.with_machine(params["machine"]) do |machine|  
    if machine.machine_detail["os"] == "windows"
    else
      @op.comment "gkv specific linux checks"
      # TODO these checks are specific for environments with SNMP and VMWare - extract
      local_partitions = machine.disk_space.select do |row|
        /^\/dev/.match(row["filesystem"])
      end.each do |partition|
        machine.add_service_config(
          "service_description" => "Disk - #{partition["mount_point"]}",
          "service_template" => "disk-template",
          "check_command" => "check_snmp_storage_used!#{partition["mount_point"]}!80!95"
        )
      end
      
      machine.add_service_config(
        "service_template" => 'generic-service',
        "service_description" => 'load',
        "check_command" => "check_snmp_load_linux!6!10"
      )
      
      machine.add_service_config(
        "service_template" => 'service-template-nop',
        "service_description" => 'Prozess VMWare Tools',
        "check_command" => "check_snmp_process!vmtoolsd"
      )
    end
  end
end
