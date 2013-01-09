description "fixes the clock setting in the libvirt config for a VM so that the host clock timezone setting is used"

param :machine
param "vm_name", "name of the vm for which the config should be fixed", :mandatory => true

on_machine do |machine, params|
  replacement_pattern = "s#<clock offset='utc'/>#<clock offset='localtime'/>#"
  machine.ssh_and_check_result('command' => "sed -i -e \"#{replacement_pattern}\" #{libvirt_config_file(params)}")
  @op.redefine_vm(params)
end
