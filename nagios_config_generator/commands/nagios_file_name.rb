description "returns the path to this machine's nagios configuration"

param! :machine

mark_as_read_only

on_machine do |machine, params|
  "#{config_string('config_root')}/#{machine.name}.cfg"
end