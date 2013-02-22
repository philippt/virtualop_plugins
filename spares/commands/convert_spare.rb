param :machine
param! "new_name", "the name for the new VM"

on_machine do |machine, params|
  details = @op.machine_detail("machine" => params["machine"])
  short_name = params["machine"].split(".").first
  
  machine.set_hostname("hostname" => params["new_name"])
  machine.ssh_and_check_result("command" => "shutdown -h now")
  
  @op.wait_until("interval" => 5, "timeout" => 120) do
    @op.vm_status("machine" => params["machine"]) == "shut off"
  end
  
  @op.rename_vm("machine" => details["host_name"], "name" => short_name, "new_name" => params["new_name"])
  
  new_details = {
    "name" => params["new_name"] + '.' + details["host_name"]
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
  
  @op.start_vm("machine" => details["host_name"], "name" => params["new_name"])
end
