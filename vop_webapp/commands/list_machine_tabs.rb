description "returns the tabs that should be displayed for a given machine"

param :machine

mark_as_read_only

display_type :table
add_columns [ :name, :title ]

on_machine do |machine, params|
  result = []
  
  tabs = [
    ["machine_overview", "Overview"],
    ["working_copies", "Working Copies"],
    ["unix_services", "Unix Services"],   
    #["log_files", "Log Files"],
    #["machine_traffic", "Traffic"],
    ["disk_space", "Diskspace"],
    ["listen_ports", "Listen Ports"],
    ["processes", "Processes"],
    ["routes", "Routes"],
    #["access_logs", "Access Logs"],
    #["nagios_checks", "Nagios Checks"],
    #["active_versions", "Active Versions"]
  ]
  
  begin
    service_names = machine.list_unix_services.map { |row| row["name"] }
    
    tabs << ["ssh_logs", "SSH Logins"]
    
    tabs << ["list_installed_services", "Services" ]
  
    if service_names.include?("libvirtd")
      tabs << ["list_vms", "Virtual Guests"] 
    end
    
    if service_names.include?("vz")
      tabs << ["list_openvz_vms", "OpenVZ guests"]
    end
    
    if service_names.include?("iptables") and machine.file_exists("file_name" => "/var/log/iptables")
      tabs << ["failed_outbound_calls", "Failed Outbound Calls"]
    end
    
    if service_names.include?("httpd")
      tabs << [ "virtual_hosts", "Virtual Hosts" ]
    end
    
    if (machine.processes().select do |process|
      /yum -y update/.match(process["command_short"])
    end.size() > 0) and (machine.file_exists("file_name" => "/var/log/yum_update.log"))
      tabs << [ "yum_update_log", "YUM update log" ]
    end
    
    if service_names.include?("varnish")
      tabs << [ "varnish_stats", "Varnish Stats" ]
    end
    
    # if service_names.include?("mysqld")
      # tabs << ["mysql_dumps", "MySQL Dumps"]
      # tabs << ["mysql_processlist", "MySQL Processes"]
    # end
  rescue
    $logger.warn "couldn't load service-specific tabs - something wrong with list_unix_services?"
  end

  if /^philipp\./.match(params["machine"])
    tabs << [ "fan", "FAN" ]    
  end

# 
  # if @show_mysql_replication_tab
    # tabs << ["mysql_replication", "MySQL Replication"]
  # end
# 
  # if @show_center_kpi_tab
    # tabs << ["center_kpi", "Business KPIs"]
  # end
  # if @show_payment_kpi_tab
    # tabs << ["payment_kpi", "Business KPIs"]
  # end
  # if @show_pyamf_kpi_tab
    # tabs << ["pyamf_kpi", "Business KPIs"]
  # end
  
  tabs.each do |parts|
    result << {
      "name" => parts[0],
      "title" => parts[1]
    }
  end
  
  result
end
