description "permanently erases the local changes to the specified file(s) and overwrites them with the latest version from the git repository"

param :machine
param :working_copy

param! "path", "the relative path (inside the working copy) to the file that should be reset"

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh("command" => "cd #{path} && git checkout -- #{params["path"]}")
  
  @op.without_cache do
    machine.list_changes_in_working_copy({}.merge_from params, :machine, :working_copy)
    machine.diff_changes_in_working_copy({}.merge_from params, :machine, :working_copy)
  end  
end
