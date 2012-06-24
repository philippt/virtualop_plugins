description "commits all local changes and pushes them onto the server"

param :machine
param :working_copy
param! "comment", "description of the changes"

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  # TODO handle branches (+ origin <branch_name>)
  machine.ssh_and_check_result("command" => "cd #{path} && git commit -a -m \"#{params["comment"]}\" && git push")
  
  @op.without_cache do
    machine.list_changes_in_working_copy("working_copy" => params["working_copy"])
  end
end  
