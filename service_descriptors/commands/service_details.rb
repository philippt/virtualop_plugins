description "reads detail information about the service from the file written during the installation"

param :machine
param :service

display_type :hash

mark_as_read_only

on_machine do |machine, params|
  content = machine.read_file("file_name" => config_string('service_config_dir') + '/' + params["service"])
  
  result = YAML.load(content)
  
  result["domain"] = result["extra_params"]["domain"] if result.has_key?("extra_params") and result["extra_params"].has_key?("domain")
  
  if result.has_key?("service_root")
    result.merge! machine.list_services_in_working_copy("working_copy" => result["service_root"]).select { |row| row["name"] == params["service"] }.first
  else
    # TODO that's a bit approximate - should use x["full_name"] here to observe the "name spacing"
    found_canned_service = @op.list_available_services("machine" => "localhost").select { |x| x["name"] == params["service"] }.first
    result.merge! found_canned_service  
  end 
  
  %w|start stop status|.each do |operation|
    if result.has_key?("unix_service") and not result.has_key?("#{operation}_command")
      # TODO merge in ubuntu-specific sudo handling from status_unix_service
      result["#{operation}_command"] = "/etc/init.d/#{result["unix_service"]} #{operation}"
    end
  end
  
  result["is_startable"] = result.has_key?("start_command") || result.has_key?("run_command")
  
  result["runlevel"] ||= "application"
  
  result
end  
