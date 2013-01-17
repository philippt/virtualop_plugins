description 'sets up a new VM based on an external kickstart generator that is called with parameters'

#TODO params_as :new_vm

param :machine
param! "vm_name", "the name for the VM to be created"
param! "memory_size", "the amount of memory (in MB) that should be allocated for the new VM"
param! "disk_size", "disk size in GB for the new VM"
param! "vcpu_count", "the number of virtual CPUs to allocate"
param! "bridge", "the network bridge that should be used"
param "sparse", "value for the 'sparse' parameter; influences virtual disk handling, see libvirt documentation (default: True)"
param! "location", "Installation source for guest virtual machine kernel+initrd pair."
param "extra_arg", "extra arguments to pass to the installer when performing an installation from 'location'", :allows_multiple_values => true

param! "kickstart_url", "http url for fetching the kickstart script"
param! "ip", "the static IP address for the new machine"
param! "gateway", "the network gateway that should be used by the new machine"
param! "nameserver", "the nameserver that should be configured into the new machine"

param "http_proxy", "if specified, the http proxy is used for the installation and configured on the new machine"

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
  
  machine.new_vm(params)
end
