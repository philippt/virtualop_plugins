description 'sets up a new VM based on an external kickstart generator that is called with parameters'

#params_as :new_vm

param :machine
param "vm_name", "the name for the VM to be created", :mandatory => true
param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :mandatory => true
param "disk_size", "disk size in GB for the new VM", :mandatory => true
param "vcpu_count", "the number of virtual CPUs to allocate", :mandatory => true
param "bridge", "the network bridge that should be used", :mandatory => true
param "sparse", "value for the 'sparse' parameter; influences virtual disk handling, see libvirt documentation (default: True)"
param "location", "Installation source for guest virtual machine kernel+initrd pair.", :mandatory => true
param "extra_arg", "extra arguments to pass to the installer when performing an installation from 'location'", :allows_multiple_values => true

param "kickstart_url", "http url for fetching the kickstart script", :mandatory => true
param "ip", "the static IP address for the new machine", :mandatory => true
param "gateway", "the network gateway that should be used by the new machine", :mandatory => true
param "nameserver", "the nameserver that should be configured into the new machine", :mandatory => true

ignore_extra_params

on_machine do |machine, p|
  params = p.clone  
  extra_args = []
  kickstart_url = params["kickstart_url"] + "?"
  %w|ip gateway nameserver|.each do |k|
    kickstart_url += "&" unless /\?$/.match(kickstart_url)
    kickstart_url += "#{k}=#{params[k]}"
    extra_args << "#{k}=#{params[k]}"
    
    # we should not pass these params along (not supported by target command)
    params.delete(k)
  end
  params.delete("kickstart_url")  
  params.delete("machine")
  
  kickstart_url += "&hostname=#{params["vm_name"]}"
  params['extra_arg'] = [ "ks=#{kickstart_url}" ]
  
  extra_args << "dns=#{p["nameserver"]}"
  extra_args << "netmask=255.255.255.0"
  extra_args << "console=ttyS0,115200"
  extra_args << "noipv6"
  
  params['extra_arg'] += extra_args
  
  #params
  machine.new_vm(params)
end
