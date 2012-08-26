description "creates a new tag on the current state of a working copy"

param :machine
param :working_copy
param! "tag", "the name of the tag that should be set"
param! "comment", "a comment message for the git operation"
param "force", "moves the tag if it already exists", :lookup_method => lambda { %w|true false| }

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  tag_options = ''
  tag_options += ' -f' if params["force"] == "true"
  machine.ssh_and_check_result("command" => "cd #{path} && git tag #{tag_options} -a #{params["tag"]} -m '#{params["comment"]}'")
  machine.ssh_and_check_result("command" => "cd #{path} && git push --tags")
end
