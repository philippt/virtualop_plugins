description "creates a new tag on the current state of a working copy"

param :machine
param :working_copy, "the working copy that should be tagged", :allows_multiple_values => true
param! "tag", "the name of the tag that should be set"
param! "comment", "a comment message for the git operation"
param "force", "moves the tag if it already exists", :lookup_method => lambda { %w|true false| }

on_machine do |machine, params|
  params["working_copy"].each do |working_copy|
    path = machine.list_working_copies.select do |w|
      w["name"] == working_copy
    end.first["path"]
    
    tag_options = ''
    tag_options += ' -f' if params["force"] == "true"
    machine.ssh("command" => "cd #{path} && git tag #{tag_options} -a #{params["tag"]} -m '#{params["comment"]}'")
    machine.ssh("command" => "cd #{path} && git push --tags")
  end
  
  # TODO invalidate list_tags
end
