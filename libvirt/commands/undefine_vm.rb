description "performs an 'undefine_vm' operation against the selected VM (this effectively removes it)"

param :machine
param :vm

on_machine do |machine, params|
  result = []
  
  # TODO check if the VM is shut down
  machine.ssh_and_check_result("command" => "virsh undefine #{params["name"]}")
  
  # TODO check that the VM has been shut down
     
  # TODO remove cached ssh-connections to this VM - they won't work anymore
      
  # re-read the VMs for the current host
end