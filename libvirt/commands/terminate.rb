description "permanently removes a VM and the data on it"

param :machine, :default_param => true

on_machine do |machine, params|
  host_name = machine.machine_detail["host_name"]
  raise "no host name found in machine details" unless host_name and host_name != ''

  vm_name = params['machine'].split('.').first
  @op.terminate_vm("machine" => host_name, "name" => vm_name)  
end
