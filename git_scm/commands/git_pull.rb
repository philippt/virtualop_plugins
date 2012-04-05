description 'calls "git pull" to update a working copy with changes from a master/remote'

param :machine
param "working_copy", "the working copy that should be used", :mandatory => true

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "cd #{params["working_copy"]} && git pull")
end