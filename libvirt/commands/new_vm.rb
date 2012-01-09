description 'invokes virt-install to create a new virtual machine'

param :machine
param "vm_name", "the name for the VM to be created", :mandatory => true
param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :mandatory => true
param "disk_size", "disk size in GB for the new VM", :mandatory => true
param "vcpu_count", "the number of virtual CPUs to allocate", :mandatory => true
param "bridge", "the network bridge that should be used", :mandatory => true
param "sparse", "value for the 'sparse' parameter; influences virtual disk handling, see libvirt documentation (default: True)"
param "location", "Installation source for guest virtual machine kernel+initrd pair.", :mandatory => true
param "extra_arg", "extra arguments to pass to the installer when performing an installation from 'location'", :allows_multiple_values => true

on_machine do |machine, params|
  image_path = "/var/lib/libvirt/images/#{params["vm_name"]}.img"
  
  sparse_param = params.has_key?('sparse') ? params['sparse'] : "True"
  
  command = "virt-install --name #{params["vm_name"]} --ram #{params["memory_size"]} --vcpus=#{params["vcpu_count"]}"
  # TODO reactivate sparse param?
  #command += " --disk path=#{image_path},size=#{params["disk_size"]},sparse=#{sparse_param}"
  command += " --disk path=#{image_path},size=#{params["disk_size"]}"
  command += " --network bridge:#{params["bridge"]} --accelerate --vnc --os-variant virtio26"

  if params.has_key?('location')
    command += " --location #{params["location"]}"
    if params.has_key?('extra_arg')
      command += " --extra-args=\"" 
      params['extra_arg'].each do |extra_arg|
        command += " #{extra_arg}"
      end
      command += "\""
    end
  end
  
  machine.ssh_and_check_result("command" => command)
  
  # ugly little side-effect: record this installation (e.g. for the iptables generator)
  dir_name = "/var/lib/virtualop/machines"
  machine.hash_to_file(
    "file_name" => "#{dir_name}/#{params["vm_name"]}", 
    "content" => params
  )
end