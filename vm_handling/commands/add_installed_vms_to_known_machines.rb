description 'adds all VMs that have been installed on a libvirt host and adds entries for them to the list of known machines'

param :machine

on_machine do |machine, params|
  machine.list_installed_vms.each do |vm|
    
    full_name = vm["vm_name"] + "." + machine.name
    
    @op.add_known_machine(
      "ssh_host" => machine.ipaddress,
      "ssh_port" => vm["ssh_port"],
      "ssh_password" => "the_password",
      "ssh_user" => "root",
      "name" => full_name,
      "type" => "vm",
      "host_name" => machine.name
    )
  end
end
