description "uploads a local backup into the xop data repository"

param :data_repo
param :machine
param :local_backup
param "service", "a service name to use instead of one that might be contained inside the backup"

add_columns [ "name", "type", "date", "host", "service" ]

on_machine do |machine, params|
  the_backup = machine.list_local_backups.select do |local_backup|
    local_backup["name"] == params["local_backup"]
  end.first
  
  service_name = params.has_key?("service") ? params["service"] : the_backup["service"]
  raise "no service name specified" if nil == service_name
  @op.create_service_dir_in_repo "service" => service_name
  
  repo = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
  machine.http_upload "target_url" => repo["url"] + '/' + service_name + '/',
    "file_name" => local_backup_dir(machine) + '/' + the_backup["name"] + '.tgz'
    
  @op.without_cache do
    uploaded = @op.list_backups_in_repo("data_repo_service" => service_name).select { |backup|
      backup["name"] == the_backup["name"]
    }
    uploaded.size > 0 || raise("could not find backup '#{the_backup["name"]}' in repo after upload")
  end
  
  [ the_backup ]
end