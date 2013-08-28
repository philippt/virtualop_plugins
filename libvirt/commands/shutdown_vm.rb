description "performs a 'shutdown' against the selected VM (that's a graceful shutdown in libvirt speak)"

param :machine
param :vm

on_machine do |machine, params|
  machine.ssh("command" => "virsh shutdown #{params["name"]}")
  sleep 15
  machine.ssh("command" => "virsh destroy #{params["name"]}")
  
  @op.without_cache do 
    machine.list_vms
  end
end