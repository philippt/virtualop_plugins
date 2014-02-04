description "adds a remote repository to a working copy's configuration"

param :machine
param :working_copy
param! "remote", "alias name for the (remote) repository configuration"
param! "url", "url to the remote repository"

on_machine do |machine, params|
  details = machine.working_copy_details("working_copy" => params["working_copy"])
  
  machine.ssh("command" => "cd #{details["path"]} && git remote add #{params["remote"]} #{params["url"]}")
end  
