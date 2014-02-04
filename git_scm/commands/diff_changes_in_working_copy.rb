description "calls git diff to get a delta of the local changes"

mark_as_read_only

param :machine
param :working_copy

param "path", "a path fragment (relative to the working copy) that is passed to 'git diff'"

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh("command" => "cd #{path} && git diff #{params["path"]}")
end  
