description 'permanently removes a working copy from the system'

param :machine
param :working_copy

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  machine.rm("recursively" => "true", "file_name" => path)
  
  # TODO cache flush
  @op.without_cache do
    machine.list_working_copies
  end
end
