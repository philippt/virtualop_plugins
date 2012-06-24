description "creates a working copy of a github project on a machine and installs the project"

param :machine
param! :github_project
param :git_branch

accept_extra_params

on_machine do |machine, params|
  project_name = params["github_project"].split("/").last
  
  service_root = "#{machine.home}/#{project_name}"
  
  git_url = "git://github.com/#{params["github_project"]}.git"
  
  p = {
    "directory" => service_root,
    "git_url" => git_url 
  }
  if params.has_key?("git_branch")
    p["git_branch"] = params["git_branch"]
  end 
  machine.git_clone(p)  
  
  #machine.load_services_from_working_copies
  machine.list_services_in_working_copies
  
  params["working_copy"] = service_root
  params["service"] = params["github_project"]
  
  if params.has_key?('extra_params')
    params["extra_params"].each do |k,v|
      params[k] = v
    end
  end
  
  machine.install_service_from_working_copy(
    params    
  )
end
