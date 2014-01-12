description  "starts a VM"

param :machine

on_machine do |machine, params|
  machine.ssh("command" => "virsh start #{params["name"]}")
  @op.comment("message" => "vm #{params["name"]} has been started.")
  
  @op.without_cache do 
    machine.list_vms
  end
end