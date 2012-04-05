description "performs a 'shutdown' against the selected VM (that's a graceful shutdown in libvirt speak)"

param :machine
param :vm

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "virsh shutdown #{params["name"]}")
  
  @op.without_cache do 
    machine.list_vms
  end
end