description "downloads the latest available backup data for this service from the repository and restores it, thereby elimininating local data."

param :data_repo
param :machine
param :service
#param :mysql_host

add_columns [ "name", "type", "date", "host", "service" ]

on_machine do |machine, params|
  #mysql_host = params.has_key?("mysql_host") ? params["mysql_host"] : "localhost"

  result = []
   
  #service = machine.read_service_descriptor("service" => params["service"])
  service = machine.service_details("service" => params["service"])
    
  # TODO reactivate datasource overrides
  # current_env = machine.current_env
#   
  # if service.datasource_overrides.has_key?(current_env)
    # source_service_name = service.datasource_overrides[current_env]
    # $logger.info "found datasource override for service '#{params["service"]}': '#{source_service_name}'" 
  # else
    # source_service_name = params["service"]
    # $logger.info "found datasource for service '#{params["service"]}': '#{source_service_name}'"
  # end
  
  source_service_name = service["full_name"].gsub(/[-\/]/, '_')
  $logger.info "restoring data for service '#{params["service"]}' from data repository (using service name '#{source_service_name}')"
    
  backups = []
  if @op.list_services_in_repo.include? source_service_name then
    backups = machine.find_last_backups_for_service("data_repo_service" => source_service_name)
  end
  if backups.size > 0 then
    backups.each do |backup|
      machine.download_backup "data_repo_service" => source_service_name, "backup_name" => backup["name"]
      p = {
        "local_backup" => backup["name"],
        "service" => params["service"]
      }
      machine.restore_backup(p)
      result << backup.clone
    end
  end
  result  
end  
