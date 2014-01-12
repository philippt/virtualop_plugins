description "calls 'virsh define' so that the VM config is read from the libvirt config again. helpful after modifications"

param :machine
param :vm, :allows_extra_values => true

on_machine do |machine, params|
  machine.ssh('command' => 'virsh define ' + libvirt_config_file(params))
end  