param :data_repo
param :machine
param :service

param :data_repo_service
param :data_repo_backup_for_service

on_machine do |machine, params|
  machine.download_backup "data_repo_service" => params["data_repo_service"], "backup_name" => params["backup_name"]
  machine.restore_backup "local_backup" => params["backup_name"], "service" => params["service"]
end  
