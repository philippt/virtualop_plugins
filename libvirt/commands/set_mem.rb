description "changes the amount of memory available for this VM (see also set_maxmem)"

param :machine
param :vm
param "value", "the new value for max_mem (in kilobytes)", :mandatory => true

on_machine do |machine, params|
  value_in_kilobyte = params['value']
  machine.ssh("command" => "virsh setmem #{params["name"]} #{value_in_kilobyte}")
end