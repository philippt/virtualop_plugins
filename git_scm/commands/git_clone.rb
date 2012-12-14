description 'clones a git repository into a new directory'

param :machine

param! "git_url", "the git URL to use"
param :git_branch
param "git_tag", "the name of a tag that should be checked out"
param "directory", "the target directory to checkout into (defaults to $HOME/project_name)"

on_machine do |machine, params|
  command = "git clone "
  if params.has_key?('git_branch') and params["git_branch"] != ''
    command += " -b #{params["git_branch"]}"
  end 
  command += " #{params["git_url"]}"
  command += " #{params["directory"]}" if params.has_key?('directory')
  machine.ssh_and_check_result("command" => command)
  
  dir = params["directory"] || machine.home + '/' + params["git_url"].split("/").last.split(".").first
  if params.has_key?('git_tag') and params["git_tag"] != ''
    machine.ssh_and_check_result("command" => "cd #{dir} && git checkout #{params["git_tag"]}")
  end
  
  @op.without_cache do
    machine.file_exists("file_name" => params["directory"])
    machine.list_working_copies
    machine.list_working_copies_with_projects
  end
end