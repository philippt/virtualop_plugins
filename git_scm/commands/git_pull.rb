description 'calls "git pull" to update a working copy with changes from a master/remote'

param :machine
param! "working_copy_path", "path to the working copy that should be used"
param "branch", "the branch to pull from"

on_machine do |machine, params|
  options = params.has_key?("branch") ? "origin #{params["branch"]}" : ''
  machine.ssh("command" => "cd #{params["working_copy_path"]} && git pull #{options}")
end