description "fixes the clock setting in the libvirt config for a VM so that the host clock timezone setting is used"

param :machine
param :vm

on_machine do |machine, params|
  replacement_pattern = "s#<clock offset='utc'/>#<clock offset='localtime'/>#"
  machine.ssh('command' => "sed -i -e \"#{replacement_pattern}\" #{libvirt_config_file(params)}")
  @op.redefine_vm(params)
end
