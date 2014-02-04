description "shutdown a virtual machine"

param :machine

execute do |params|
  vm_name = params['machine'].split('.').first
  details = @op.machine_detail(params)
  @op.shutdown_vm("machine" => details["host_name"], "name" => vm_name)
end
