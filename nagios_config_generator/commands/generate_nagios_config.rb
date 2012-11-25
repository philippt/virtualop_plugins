description "generates nagios configuration for a machine"

param :machine
param "alternative_mysql_host_name", "if mysql checks are generated, the value of this parameter is used instead of the host address as mysql hostname to connect against"

on_machine do |machine, params|
  target_file = machine.nagios_file_name

  local_partitions = machine.disk_space.select do |row|
    /^\/dev/.match(row["filesystem"])
  end

  template_name = machine.machine_detail.has_key?('dns_name') ?
    :ec2_instance :
    :machine
    
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    process_local_template(template_name, nagios, target_file, binding())    
    nagios.chmod("file_name" => target_file, "permissions" => "644")
  
    default_services = config_string('default_services', [])
    default_services.each do |name|
      machine.add_config_from_template("template_name" => name)
    end
  
    unix_services = machine.list_unix_services
    if unix_services.include?('apache2') and machine.status_unix_service("name" => 'apache2')
      apache_checks = read_local_template(:apache, binding())
      nagios.append_to_file("file_name" => target_file, "content" => apache_checks)
    end
    
    # if unix_services.include?('mysql') and machine.status_unix_service("name" => 'mysql')
      # mysql_target = params.has_key?('alternative_mysql_host_name') ? params['alternative_mysql_host_name'] : '$HOSTADDRESS$'
      # mysql_checks = read_local_template(:mysql, binding())
      # nagios.append_to_file("file_name" => target_file, "content" => mysql_checks)
    # end
  end
  
  nagios_public_key = @op.with_machine(config_string('nagios_machine_name')) do |nagios|
  #  #nagios.list_authorized_keys.first
  #  puts "nagios home : #{nagios.home}"
    nagios.read_file("file_name" => '/home/nagios/.ssh/id_rsa.pub')
  end
  #nagios_public_key = machine.read_file("file_name" => "/home/nagios/.ssh/id_rsa.pub")
  machine.add_authorized_key("public_key" => nagios_public_key) unless machine.list_authorized_keys.include? nagios_public_key
  
  machine.list_services.each do |service|
    if service.has_key?("domain")
      machine.add_service_config("check_command" => "check_http_domain!#{service["domain"]}", "service_description" => "#{service["domain"]}")
    end
  end
  
  @op.reload_nagios
  
  if @op.list_plugins.include? 'nagios_status'
    @op.without_cache do
      machine.list_nagios_checks
    end
  end
end
