description "initializes an empty github repo so that working copies can be cloned from it"

param :machine

github_params
param! "github_repo", "the repository that should be initialized", :lookup_method => lambda {
    @op.list_github_repos.map { |x| 
      x["full_name"]
    }
  }
#param "project_name", ""
  
on_machine do |machine, params|
  repo = @op.list_github_repos.map { |x| 
      x["full_name"] == params["github_repo"]
  }.first
  
  # TODO wtf?!?
  machine.ssh_and_check_result("command" => "mkdir erosintl")
  machine.ssh_and_check_result("command" => "cd erosintl && git init")
  machine.ssh_and_check_result("command" => "cd erosintl && touch README && git add README")
  machine.ssh_and_check_result("command" => "cd erosintl && git commit -m 'first commit'")
  machine.ssh_and_check_result("command" => "cd erosintl && git remote add origin #{repo["ssh_url"]}")
  machine.ssh_and_check_result("command" => "cd erosintl && git push -u origin master")
end  


