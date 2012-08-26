description "commits changes in all tracked files and pushes the changes to the default remote repository"

param :machine
param :working_copy
param! "comment", "description of the changes"

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh_and_check_result("command" => "cd #{path} && git commit -a -m \"#{params["comment"]}\"")
  
  machine.push_working_copy("working_copy" => params["working_copy"])
  
  @op.without_cache do
    machine.list_changes_in_working_copy("working_copy" => params["working_copy"])
  end
end  
