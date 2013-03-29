param :machine
param! "new_name", "the name for the new VM"

param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 25
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

on_machine do |machine, params|
  details = @op.machine_detail("machine" => params["machine"])
  short_name = params["machine"].split(".").first
  
  machine.set_hostname("hostname" => params["new_name"])
  machine.ssh("command" => "shutdown -h now")
  
  @op.wait_until("interval" => 5, "timeout" => 120) do
    @op.vm_status("machine" => params["machine"]) == "shut off"
  end
  
  @op.rename_vm("machine" => details["host_name"], "name" => short_name, "new_name" => params["new_name"])
  
  new_full_name = params["new_name"] + '.' + details["host_name"]
  new_details = {
    "name" => new_full_name
  }
  details.each do |k,v|
    if %w|host_name os ssh_host ssh_key ssh_password ssh_port ssh_user type|.include? k
      new_details[k] = v
    end
  end  
  @op.add_known_machine(new_details)
  
  @op.without_cache do
    @op.list_machines
    @op.list_vms("machine" => details["host_name"])
  end
  
  @op.set_maxmem("machine" => details["host_name"], "name" => params["new_name"],"value" => (params["memory_size"].to_i * 1024))
  # TODO set_mem or adjust xml file
  
  # TODO adjust disk & cpu
  
  @op.start_vm("machine" => details["host_name"], "name" => params["new_name"])
  
  sleep 10
  
  @op.wait_until("interval" => 5, "timeout" => 120) do
    (@op.vm_status("machine" => new_full_name) == "running") &&
    # TODO damn you, Mr. T.
    (@op.reachable_through_ssh("machine" => new_full_name) == "true")
  end
  
  @op.set_mem("machine" => details["host_name"], "name" => params["new_name"],"value" => (params["memory_size"].to_i * 1024))
  
  sleep 10
  
  new_full_name
end


