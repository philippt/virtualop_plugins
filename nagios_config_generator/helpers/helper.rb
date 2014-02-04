def nagios_file_name(machine)
  raise "boom"
  "#{config_string('config_root')}/#{machine.name}.cfg"
end

def check_ssh_string(machine)
  options = @op.ssh_options_for_machine("machine" => machine.name)
  "check_ssh_explicit!#{options["port"]}!#{options["host"]}"
end
