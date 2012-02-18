def nagios_file_name(machine)
  "#{config_string('config_root')}/#{machine.name}.cfg"
end
