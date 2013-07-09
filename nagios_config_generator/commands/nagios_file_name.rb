description "returns the path to this machine's nagios configuration"

param! :machine

mark_as_read_only

on_machine do |machine, params|
  machine_name = machine.name == "localhost" ? machine.hostname : machine.name
    detail = machine.machine_detail
    "#{config_string('config_root')}/#{detail["os"]}/#{machine_name.downcase}.cfg"
end