description "creates a working copy of a github project on a machine and installs the project"

github_params

param :machine
param! :github_project
param :git_branch
param :git_tag

accept_extra_params

on_machine do |machine, params|
  project_name = params["github_project"].split("/").last
  service_root = "#{machine.home}/#{project_name}"
  
  if params.has_key?('extra_params') and params["extra_params"].has_key?("domain")
    service_root = "/var/www/#{project_name}"
  end
  
  @op.github_clone({"directory" => service_root}.merge_from(params, :machine, :github_project, :git_branch, :git_tag))
  
  machine.list_services_in_working_copies
  
  params["working_copy"] = project_name # TODO is that a good idea? (used to be the path)
  params["service"] = project_name
  
  if params.has_key?('extra_params')
    params["extra_params"].each do |k,v|
      params[k] = v
    end
  end
  
  params["version"] = {}.merge_from params, :github_project, :git_branch, :git_tag
  
  machine.install_service_from_working_copy(params)
end
