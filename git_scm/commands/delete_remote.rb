description "removes a remote repository configuration from a working copy's config"

param :machine
param :working_copy
param! "remote", "the name of the remote (repository configuration)", :lookup_method => lambda { |request|
  @op.list_remotes("machine" => request.get_param_value("machine"), "working_copy" => request.get_param_value("working_copy")).map { |x| x["name"] } 
}

on_machine do |machine, params|
  details = machine.working_copy_details("working_copy" => params["working_copy"])
  
  machine.ssh("command" => "cd #{details["path"]} && git remote rm #{params["remote"]}")
end
