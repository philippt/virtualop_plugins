description 'clones a git repository into a new directory'

param :machine

param "git_url", "the git URL to use", :mandatory => true
param "directory", "the target directory to checkout into (defaults to $HOME/project_name)"
param :git_branch

on_machine do |machine, params|
  command = "git clone "
  if params.has_key?('git_branch') and params["git_branch"] != ''
    command += " -b #{params["git_branch"]}"
  end 
  command += " #{params["git_url"]}"
  command += " #{params["directory"]}" if params.has_key?('directory')
  machine.ssh_and_check_result("command" => command)
end