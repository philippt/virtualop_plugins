description "registers a new file to the version control system so that it may be tracked from now on ever after"

param :machine
param :working_copy
param! "file_name", "the file that should be added"

display_type :list

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh("command" => "cd #{path} && git add #{params["file_name"]}")
  
  @op.without_cache do
    machine.list_changes_in_working_copy("working_copy" => params["working_copy"])
  end
end  
