description "commits changes in all tracked files"

param :machine
param :working_copy
param! "comment", "description of the changes"

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh("command" => "cd #{path} && git commit -a -m \"#{params["comment"]}\"")
  
  @op.without_cache do
    machine.list_changes_in_working_copy("working_copy" => params["working_copy"])
  end
end  
