description "updates the configuration of a working copy so that it uses ssh to connect to github"

param :machine
param :working_copy

on_machine do |machine, params|
  name = params["working_copy"]
  details = machine.working_copy_details("working_copy" => name)
  
  machine.delete_remote("working_copy" => name, "remote" => "origin")
  machine.add_remote("working_copy" => name, "remote" => "origin", "url" => "git@github.com:#{details["project"]}.git")
end
