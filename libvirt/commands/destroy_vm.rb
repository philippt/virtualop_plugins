description "performs a 'destroy' operation against the selected VM (that does not destroy the VM, but rather forces a shutdown)"

param :machine
param :vm

on_machine do |machine, params|
  machine.ssh("command" => "virsh destroy #{params["name"]}")
  
  @op.without_cache do 
    machine.list_vms
  end
end
