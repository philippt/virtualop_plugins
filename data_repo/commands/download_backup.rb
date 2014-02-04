description "downloads data from the xop data repository onto the local disk"

param :machine
param :data_repo
param :data_repo_service
param :data_repo_backup_for_service

on_machine do |machine, params|
  if machine.list_local_backups.select do |backup|
    backup["name"] == params["backup_name"]
  end.size > 0 then
    $logger.info "backup #{params["backup_name"]} exists already locally, not downloading again."
  else
    backup_dir = local_backup_dir(machine)
    repo_row = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
    
    machine.mkdir("dir_name" => backup_dir)
    machine.wget(
      "url" => repo_row["url"] + '/' + params["data_repo_service"] + '/' + params["backup_name"] + '.tgz',
      "target_dir" => backup_dir
    )
      
    @op.without_cache do
      machine.list_local_backups
      machine.list_dumps  
    end
  end
end    
