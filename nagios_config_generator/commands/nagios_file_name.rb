description "returns the path to this machine's nagios configuration"

param! :machine

mark_as_read_only

on_machine do |machine, params|
  machine_name = machine.name == "localhost" ? machine.hostname : machine.name
  "#{config_string('config_root')}/#{machine_name}.cfg"
end