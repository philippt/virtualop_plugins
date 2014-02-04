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
    ["working_copies_new", "Working Copies New"],
    ["status_working_copies", "Status Working Copies"],
    ["log_files", "Log Files"],
    #["machine_traffic", "Traffic"],
    ["disk_space", "Diskspace"],
    ["listen_ports", "Listen Ports"],
    ["processes", "Processes"],
    ["routes", "Routes"],
    ["packages", "Packages"]
    #["access_logs", "Access Logs"],
    #["nagios_checks", "Nagios Checks"],
    #["active_versions", "Active Versions"]
  ]
  
  case machine.machine_detail["os"]
  when "windows"
    tabs << [ "windows_services", "Windows Services" ]
  when "linux"
    tabs << ["unix_services", "Unix Services"]
    tabs << ["system_users", "Users"]
  end
  
  tabs << ["list_services", "Services"]
  
  begin
    service_names = machine.list_unix_services #.map { |row| row["name"] }
    services = machine.list_services.map { |x| x["name"] }
    
    #tabs << ["ssh_logs", "SSH Logins"]
  
    if service_names.include?("libvirtd")
      tabs << ["list_vms", "Virtual Guests"] 
      tabs << ["list_vms_with_memory", "VMs w/ memory"]
    end
    
    if service_names.include?("vz")
      tabs << ["list_openvz_vms", "OpenVZ guests"]
    end
    
    if service_names.include?("iptables") and machine.file_exists("file_name" => "/var/log/iptables")
      tabs << ["failed_outbound_calls", "Failed Outbound Calls"]
    end
    
    if services.include? "apache" #service_names.include?("httpd")
      tabs << [ "virtual_hosts", "Virtual Hosts" ]
    end
    
    if services.include? "selenium"
      tabs << [ "selenium_tests", "Selenium" ]
    end
    
    if (machine.processes().select do |process|
      /yum -y update/.match(process["command_short"])
    end.size() > 0) and (machine.file_exists("file_name" => "/var/log/yum_update.log"))
      tabs << [ "yum_update_log", "YUM update log" ]
    end
    
    if service_names.include?("varnish")
      tabs << [ "varnish_stats", "Varnish Stats" ]
    end
    
    if service_names.include?("mysqld") or service_names.include?("mysql")
      tabs << [ "list_databases", "Databases" ]
      #tabs << ["mysql_dumps", "MySQL Dumps"]
      #tabs << ["mysql_processlist", "MySQL Processes"]
    end
  rescue
    $logger.warn "couldn't load service-specific tabs - something wrong with list_unix_services?"
  end
  
  begin
    service_names = machine.list_services.map { |x| x["name"] }
    
    tabs << [ "dropbox", "Dropbox" ] if service_names.include? "dropbox"
  rescue => detail
    
  end
  
  if @op.list_plugins.include?('nagios_status')
    tabs << [ "nagios_checks", "Monitoring" ]
  end

  if @op.list_plugins.include?('xoplogs')
    begin
      if machine.list_services_with_access_logs.size > 0
        tabs << [ "machine_traffic", "Traffic" ]
      end
    rescue => detail
      $logger.warn "could not list_services_with_access_logs.size : #{detail.message}"
    end
  end
  
  if @op.list_plugins.include?('vmware_rvc') and @op.machine_by_name("machine" => params["machine"])["type"] == "host"
    tabs << [ "list_vms", "Virtual Guests" ]
  end
  
  if @op.list_plugins.include?('gkv_release_repo')
    tabs << [ "list_deployed_releases", "Releases" ]
  end
  
  if @op.list_plugins.include?('bigip')
    tabs << [ "bigip", "BigIP" ]
  end
 
  tabs << [ "machine_history", "History" ]
  tabs << [ "machine_permissions", "Permissions" ]

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
 
