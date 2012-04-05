description 'removes all VMs from the list of installed machines that do not exist anymore'

param :machine

on_machine do |machine, params|
  existing_vms = machine.list_vms()
  machine.list_installed_vms.each do |moriturus|
    candidates = existing_vms.select do |c|
      c["name"] == moriturus["vm_name"]
    end
    unless candidates.size > 0
      @op.remove_installed_vm_entry("name" => moriturus["vm_name"], "cache_update" => "nothx")
    end
  end
  
  @op.without_cache do
    @op.list_installed_vms()
  end
end
