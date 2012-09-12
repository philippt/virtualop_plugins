description "checks in the repository if there's a service directory for the specified service and creates it if not"

param :data_repo  
param! "service", "name of the service"

execute do |params|
  if @op.list_services_in_repo.include?(params['service']) then
    $logger.info "service directory exists already, nothing to do..."
  else
    repo = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
    @op.with_machine(repo["machine"]) do |machine|
      docroot = machine.list_configured_vhosts().first["document_root"].strip
      service_dir = "#{docroot}/#{params["service"]}"
      
      machine.mkdir("dir_name" => service_dir)      
    end
  end
end
