description 'setup a new vm, providing some defaults for new_vm_from_kickstart'

param :machine

param "vm_name", "the name for the VM to be created", :mandatory => true
param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 5
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

param "ip", "the static IP address for the new machine"

param "domain", "the domain at which the service should be available"
param "script_url", "http URL to a script that should be executed at the end of the installation"
param "location", "installation source for guest virtual machine kernel+initrd pair."

on_machine do |machine, params|  
  
  full_name = params["vm_name"] + "." + machine.name
  params["ip"] = machine.next_free_ip unless params.has_key?('ip') 
   
  parts = params["ip"].split("\.")[0..2]
  parts << '1'
  gateway = parts.join(".")
  
  location_default = config_string('install_kernel_location')
  defaults = {
    "bridge" => "br10",
    "location" => location_default,
    "kickstart_url" => "http://demo.virtualop.org/kickstart/centos6_minimal",
    "nameserver" => machine.first_configured_nameserver,
    "gateway" => gateway
  }
  defaults.each do |k,v|
    params[k] = v unless params.has_key?(k)
  end
  
  @op.notify_vm_setup_start("machine_name" => full_name, "data" => params)
  
  new_vm_params = params.clone
  new_vm_params.delete("domain")
  new_vm_params.delete("script_url")
  machine.new_vm_from_kickstart(new_vm_params)

  # TODO does not work without memcached
  @op.flush_cache
  
  machine.generate_and_execute_iptables_script
  
  machine.add_installed_vms_to_known_machines
  @op.without_cache do
    @op.list_known_machines
    @op.list_machines
  end
  
  # wait until shutdown after installation
  @op.wait_until(
    "interval" => 5, "timeout" => 900, 
    "error_text" => "could not find a machine with name '#{params["vm_name"]}' that is shut off",
    "condition" => lambda do
      candidates = machine.list_vms.select do |row|
        row["name"] == params["vm_name"] and
        row["state"] == "shut off"
      end
      candidates.size > 0
    end
  )
  
  machine.fix_libvirt_timezone_config("vm_name" => params["vm_name"])
  
  # startup
  machine.start_vm("name" => params["vm_name"])
  
  sleep 15
  
  @op.wait_until(
    "interval" => 5, "timeout" => 120, 
    "error_text" => "could not find a running machine with name '#{params["vm_name"]}'",
    "condition" => lambda do
      result = false
      begin
        @op.with_machine(full_name) do |machine|
          machine.hostname
        end      
        result = true
      rescue Exception => e
        $logger.info("got an exception while trying to connect to machine : #{e.message}")
      end
      result
    end
  )
  
  @op.with_machine(full_name) do |vm|
    vm.ssh_and_check_result("command" => "setenforce Permissive")
    vm.ssh_and_check_result("command" => "restorecon -R -v /root/.ssh")
    
    vm.ssh_and_check_result("command" => "sed -i -e 's!#PermitUserEnvironment no!PermitUserEnvironment yes!' /etc/ssh/sshd_config")
    # TODO add public keys and deactivate password login
    vm.ssh_and_check_result("command" => "/etc/init.d/sshd restart")
    
    vm.write_own_centos_repo()
    
    vm.yum_update
    @op.comment("message" => "OS package update complete.")
    
    #machine.install_vm(p)
    
    if params.has_key?('script_url')
      vm.execute_remote_command("url" => params['script_url'])
    end
    
    machine.notify_vm_setup_complete("data" => params)    
  end
end
