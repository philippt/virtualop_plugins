description "reads detail information about the service from the file written during the installation"

param :machine
param :service

display_type :hash

mark_as_read_only

on_machine do |machine, params|
  content = machine.machine_detail["os"] == "windows" ?
    machine.win_read_file("file_name" => '.vop/services/' + params["service"]) :
    machine.read_file("file_name" => machine.config_dir + '/' + params["service"])
  
  result = YAML.load(content)
  
  known_extra_params = %w|domain release_repo release|
  known_extra_params.each do |key|
    if result.has_key?("extra_params") && result["extra_params"].has_key?(key)
      result[key] = result["extra_params"][key]
    end 
  end
  
  if result.has_key?("service_root")
    if result.has_key?("descriptor_machine") && result["descriptor_machine"] == machine.name
      found = machine.list_services_in_directory("directory" => result["service_root"]).select { |row| row["name"] == (params["service"].split('/').last) }
      raise "did not find service descriptor for service '#{params["service"]}' - looked at #{result["service_root"]}. weird." if found.size == 0
      result.merge! found.first
    end
  else
    full_name = params["service"]
    unless full_name.include? '/'
      full_name += '/' + full_name
    end
    begin 
      result.merge! @op.canned_service_detail(full_name)
    rescue => detail
      $logger.warn "could not load canned service details for service '#{full_name}' : #{detail.message}"
    end
    # TODO that's a bit approximate - should use x["full_name"] here to observe the "name spacing"
    #found_canned_service = @op.list_available_services("machine" => "localhost").select { |x| x["name"] == params["service"] }.first
    #if found_canned_service
    #  result.merge! found_canned_service
    #else
    #  # TODO this happens if services have been installed with a different vop instance
    #  $logger.warn("did not find canned service #{params["service"]} - a bit odd.")
    #end  
  end 

  result["is_startable"] = result.has_key?("start_command") || result.has_key?("start_block") || 
    result.has_key?("run_command") || result.has_key?("windows_service") || result.has_key?("unix_service")   
  
  result["runlevel"] ||= "application"
  
  result
end  
