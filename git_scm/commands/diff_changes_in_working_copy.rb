description "calls git diff to get a delta of the local changes"

mark_as_read_only

param :machine
param :working_copy

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  result = []
  
  machine.ssh_and_check_result("command" => "cd #{path} && git diff")
end  
