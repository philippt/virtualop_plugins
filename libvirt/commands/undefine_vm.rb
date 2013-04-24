description "performs an 'undefine_vm' operation against the selected VM (this effectively removes it)"

param :machine
param :vm

on_machine do |machine, params|
  result = []
  
  # TODO check if the VM is shut down
  
  begin  
    machine.ssh("command" => "virsh undefine #{params["name"]}")
  rescue => detail
    if /Refusing to undefine/.match(detail.message)
      machine.ssh("command" => "virsh managedsave-remove #{params["name"]}")
      machine.ssh("command" => "virsh undefine #{params["name"]}")
    end
  end
  
  # TODO check that the VM has been shut down
     
  # TODO remove cached ssh-connections to this VM - they won't work anymore
      
  # re-read the VMs for the current host
end