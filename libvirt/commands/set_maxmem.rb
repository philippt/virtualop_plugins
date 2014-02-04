description "sets the maximally available amount of memory for this VM"

param :machine
param :vm
param "value", "the new value for max_mem (in kilobytes)", :mandatory => true

on_machine do |machine, params|
  value_in_kilobyte = params['value']
  machine.ssh("command" => "virsh setmaxmem #{params["name"]} #{value_in_kilobyte}")
end
