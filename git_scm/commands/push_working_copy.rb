description "commits all local changes and pushes them onto the server"

param :machine
param :working_copy

on_machine do |machine, params|
  details = machine.working_copy_details("working_copy" => params["working_copy"])
  path = details.path
  
  # TODO handle branches (+ origin <branch_name>)
  machine.ssh_and_check_result("command" => "cd #{path} && git push")
end  
