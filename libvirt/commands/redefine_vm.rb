description "calls 'virsh define' so that the VM config is read from the libvirt config again. helpful after modifications"

param :machine
param! "vm_name"

on_machine do |machine, params|
  machine.ssh_and_check_result('command' => 'virsh define ' + libvirt_config_file(params))
end  