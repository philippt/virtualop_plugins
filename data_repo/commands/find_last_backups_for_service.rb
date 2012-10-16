description "searches in the data repository for backups matching the specified service"

param :machine
param :data_repo
param :data_repo_service
param "data_type", "type of backup that should be searched for", :default_value => 'all', :lookup_method => lambda { %w|db file all| }

mark_as_read_only

response_type_backup

on_machine do |machine, params|
  result = []
  backups_for_this_service = []

  if @op.list_services_in_repo.include? params["data_repo_service"] then
    backups_for_this_service = @op.list_backups_in_repo "data_repo_service" => params["data_repo_service"]
  end      

    
  # all databases are backed up as one backup-item, so we need only download one for this service    
  db_backups = backups_for_this_service.select do |backup|
    backup["type"] == "db"
  end.sort do |a,b|
    a["date"] <=> b["date"]
  end.reverse
  
  # and we take the newest version of the local files
  file_backups = backups_for_this_service.select do |backup|
    backup["type"] == "file"
  end.sort do |a,b|
    a["date"] <=> b["date"]
  end.reverse

  #data_type = params.has_key?("data_type") ? params["data_type"] : "all"
  data_type = params["data_type"]

  if params["data_type"] == "db"
    result << db_backups.first if db_backups.size > 0
  elsif params["data_type"] == "file"
    result << file_backups.first if file_backups.size > 0
  else
    result << db_backups.first if db_backups.size > 0
    result << file_backups.first if file_backups.size > 0      
  end
  
  result
end
