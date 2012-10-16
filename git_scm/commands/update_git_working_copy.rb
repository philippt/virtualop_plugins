description 'pulls new changes into a working copy'

param :machine
param :working_copy
  
on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  active_branch = machine.list_branches_for_working_copy("working_copy" => params["working_copy"]).select { |x| x["active"] == "true" }.first["name"]
  puts "active branch : #{active_branch}"
  
  machine.git_pull("working_copy_path" => path, "branch" => active_branch)
end