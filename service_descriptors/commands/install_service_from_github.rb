description "creates a working copy of a github project on a machine and installs the project"

github_params

param :machine
param! :github_project
param :git_branch

accept_extra_params

on_machine do |machine, params|
  project_name = params["github_project"].split("/").last
  service_root = "#{machine.home}/#{project_name}"
  
  if params.has_key?('extra_params') and params["extra_params"].has_key?("domain")
    service_root = "/var/www/#{project_name}"
  end
  
  git_url = "git://github.com/#{params["github_project"]}.git"
  
  begin  
    project_row = @op.list_github_repos(params).select { |x| x["full_name"] == params["github_project"] }.first
    git_url = "git@github.com:#{params["github_project"]}.git" if project_row["private"] == "true"
  rescue => detail
    raise detail unless /^need either/.match(detail.message)
  end
      
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
  
  params["working_copy"] = project_name # TODO is that a good idea? (used to be the path)
  params["service"] = params["github_project"]
  
  if params.has_key?('extra_params')
    params["extra_params"].each do |k,v|
      params[k] = v
    end
  end
  
  machine.install_service_from_working_copy(params)
end
