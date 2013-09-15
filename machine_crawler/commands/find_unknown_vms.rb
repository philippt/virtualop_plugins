description 'list all VMs that have been installed on a libvirt host and are not yet contained in list_machines'

param :machine

result_as :list_known_machines

on_machine do |machine, params|
  result = []
  
  machine.list_installed_vms.each do |vm|
    
    full_name = vm["vm_name"] + "." + machine.name

    result << {    
      "os" => "linux",
      "ssh_host" => machine.ipaddress,
      "ssh_port" => vm["ssh_port"],
      "name" => full_name,
      "type" => "vm",
      "host_name" => machine.name
    }
  end
  
  result.delete_if { |x| @op.list_machines.map { |y| y["name"] }.include? x["name"] }
  
  result
end
