description "returns the tags that are set on the specified working copy resp. the associated repo thingy"

mark_as_read_only

param :machine
param :working_copy

display_type :list

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  output = machine.ssh("command" => "cd #{path} && git tag")
  output.split("\n").map { |line| line.chomp }
end
