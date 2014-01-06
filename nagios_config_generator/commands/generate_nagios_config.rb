description "generates nagios configuration for a machine"

param :machine
param "disable_notifications", "if set to 'true', notifications will be disabled", :lookup_method => lambda { %w|true false| }, :default_value => config_string('disable_generated_notifications', 'true')

on_machine do |machine, params|
  monitoring_services = config_string('default_monitoring_services', '').split(',')
  monitoring_services.each do |service_name|
    machine.install_canned_service("service" => "#{service_name}/#{service_name}")
  end
  @op.without_cache do
    machine.list_services
  end
  
  notifications_enabled = params['disable_notifications'] == 'false'
  
  target_file = machine.nagios_file_name

  template_name = machine.machine_detail.has_key?('dns_name') ?
    :ec2_instance :
    (machine.machine_detail.has_key?("os") and machine.machine_detail["os"] == "windows") ?
      :windows_machine : :machine

  ipaddress = nil
  case machine.machine_detail["os"]
  when "windows"
    reported_hostname = @op.vm_detail("machine_name" => machine.name)["hostname"]
    if matched = /.+\(([\d\.]+)\)/.match(reported_hostname)
      ipaddress = matched.captures.first
    else
      raise "could not parse IP address from VMware output - input is #{reported_hostname}"
    end
  else
    ipaddress = machine.ipaddress
    # TODO
    #raise "don't know how to get IP address for machine #{machine.name} - unsupported OS #{machine.machine_detail["os"]}"
  end

  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    process_local_template(template_name, nagios, target_file, binding())    
    nagios.chmod("file_name" => target_file, "permissions" => "644")
  
    default_services = config_string('default_services', [])
    default_services.each do |name|
      machine.add_config_from_template("template_name" => name)
    end
  
    # TODO reactivate through apache service descriptor
    if ('world' == 'perfect')
      unix_services = machine.list_unix_services
      if unix_services.include?('apache2') and machine.status_unix_service("name" => 'apache2')
        apache_checks = read_local_template(:apache, binding())
        nagios.append_to_file("file_name" => target_file, "content" => apache_checks)
      end
    end
    
    # TODO i think this should be covered by more recent changes in the my_sql plugin - check and kill
    # if unix_services.include?('mysql') and machine.status_unix_service("name" => 'mysql')
      # mysql_target = params.has_key?('alternative_mysql_host_name') ? params['alternative_mysql_host_name'] : '$HOSTADDRESS$'
      # mysql_checks = read_local_template(:mysql, binding())
      # nagios.append_to_file("file_name" => target_file, "content" => mysql_checks)
    # end
  end
  
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
  #  #nagios.list_authorized_keys.first
  #  puts "nagios home : #{nagios.home}"
    key_file = '/home/nagios/.ssh/id_rsa.pub'
    if nagios.file_exists("file_name" => key_file) # && machine.machine_detail["os"] == "linux"
      nagios_public_key = nagios.read_file("file_name" => key_file)
      machine.add_authorized_key("public_key" => nagios_public_key) unless machine.list_authorized_keys.include? nagios_public_key
    end
  end
  #nagios_public_key = machine.read_file("file_name" => "/home/nagios/.ssh/id_rsa.pub")
  machine.additional_nagios_config
  
  machine.list_services.each do |service|
    if service.has_key?("domain")
      domain = service["domain"].is_a?(Array) ? service["domain"].first : service["domain"]
      machine.add_service_config("check_command" => "check_http_domain!#{domain}", "service_description" => "http #{domain}")
    end
    
    if service.has_key?("nagios_commands")
      service["nagios_commands"].each do |name, content|
        @op.add_extra_command("file_name" => name, "content" => content)
      end
    end
    
    if service.has_key?("nagios_checks")
      service["nagios_checks"].each do |name, check|
        machine.add_service_config("check_command" => check, "service_description" => name)
      end
    end
    
  end
  
  @op.reload_nagios
  
  if @op.list_plugins.include? 'nagios_status'
    @op.without_cache do
      machine.list_nagios_checks
    end
  end
end
