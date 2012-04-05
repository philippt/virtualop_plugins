description "creates a working copy of a github project on a machine and installs the project"

param :machine
param! :github_project
param :git_branch
#param :domain

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
  
  machine.install_service_from_working_copy(
    "working_copy" => service_root    
  )
end
