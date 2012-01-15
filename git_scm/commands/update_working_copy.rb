description 'pulls new changes into a working copy'

param :machine
param :working_copy
  
on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.git_pull("working_copy" => path)
end