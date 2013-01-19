description "adds metadata for a service to a project living inside the dropbox"

param :dropbox_token
param :dropbox_project
param! "name", "name for the service"
param! "content", "service descriptor"

execute do |params|
  with_dropbox(params) do |client|
    project_dir = "/projects/#{params["project"]}"
    dotvop_dir = project_dir + "/.vop"
    
    service_dir = dotvop_dir + '/services'
    @op.dropbox_mkdir("path" => service_dir)
    
    service_name = params["name"]
    client.put_file("#{service_dir}/#{service_name}.rb", params["content"], true) # overwrite
    
    install_command_file = [ dotvop_dir, '/commands/', "#{service_name}_install.rb" ].join("/")
    install_command = read_local_template(:install_command, binding())
    client.put_file(install_command_file, install_command, true) # overwrite
  end 
  
  @op.without_cache do
    @op.list_services_in_dropbox_project("project" => params["project"])
  end
end    
