param :machine
param :working_copy

add_columns [ :sha, :comment ]

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.git_log('path' => path)
end  
