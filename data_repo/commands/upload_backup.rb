description "uploads a local backup into the xop data repository"

param :data_repo
param :machine
param :local_backup

add_columns [ "name", "type", "date", "host", "service" ]

on_machine do |machine, params|
  the_backup = machine.list_local_backups.select do |local_backup|
    local_backup["name"] == params["local_backup"]
  end.first
  
  @op.create_service_dir_in_repo "service" => the_backup["service"]
  
  repo = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
  machine.http_upload "target_url" => repo["url"] + '/' + the_backup["service"] + '/',
    "file_name" => config_string('local_backup_dir') + '/' + the_backup["name"] + '.tgz'
  
  [ the_backup ]
end