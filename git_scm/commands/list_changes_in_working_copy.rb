description "returns a list of files that have been changed inside this working copy"

mark_as_read_only

param :machine
param :working_copy

add_columns [ :status, :path ]

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.ssh("command" => "cd #{path} && git status --porcelain").split("\n").map do |line|
    matched = /(.{2})(.+)/ =~ line
    { "status" => case $1
        when " M"
          "modified"
        when "??"
          "untracked"
        else
          $1
        end,
      "path" => $2 
    }
  end
end  
