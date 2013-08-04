description "initializes an empty github repo so that working copies can be cloned from it"

param :machine
param "directory", "the directory in which the working copy should be initialized"

github_params
param! "github_repo", "the repository that should be initialized", :lookup_method => lambda {
    @op.list_github_repos.map { |x| 
      x["full_name"]
    }
  }
#param "project_name", ""
  
on_machine do |machine, params|
  repo = @op.list_github_repos.select { |x| 
      x["full_name"] == params["github_repo"]
  }.first
  
  # TODO untested
  project_name = params["github_repo"].split("/").last
  #machine.ssh_and_Check_result("command" => "mkdir #{project_name}")
  dir_name = params.has_key?("directory") ? params["directory"] : project_name
  machine.mkdir("dir_name" => dir_name)
  [
    "git init",
    "touch README && git add README",
    "git commit -m 'first commit'",
    "git remote add origin #{repo["ssh_url"]}",
    "git push -u origin master"
  ].each do |x|
    machine.ssh("command" => "cd #{dir_name} && #{x}")
  end
end  


