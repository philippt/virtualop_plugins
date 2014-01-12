description "returns a list of all backups found in the repository"

param :data_repo
param :data_repo_service

mark_as_read_only

add_columns [ "name", "type", "date", "host", "service" ]

execute do |params|
  result = []
    
  @op.list_services_in_repo.each do |service_name|
    next if params.has_key?('data_repo_service') and params['data_repo_service'] != service_name
    
    repo_row = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
    @op.read_apache_dir_listing({
      "url" => repo_row['url'] + '/' + service_name + '/'
    }).each do |dump|
      result += @op.decode_backup_filename "filename" => dump
    end      
  end
  
  result
end  