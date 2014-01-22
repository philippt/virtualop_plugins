description "creates a new directory on a machine that might be converted into a working copy later (now thats specific)"

param :machine
param! 'name'

on_machine do |machine, params|
  path = "#{machine.home}/#{params['name']}"
  machine.mkdir path
  machine.initialize_vop_project('name' => params['name'], 'directory' => path)
  
  @op.without_cache do
    machine.list_working_copies
  end
end

