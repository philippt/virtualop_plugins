description 'returns a list of vms that have been installed by the virtualop on this libvirt host'

param :machine

mark_as_read_only

add_columns [ :vm_name, :ipaddress, :ssh_port ]

on_machine do |machine, params|
  result = []
  dir_name = "/var/lib/virtualop/machines/"
  if machine.file_exists("file_name" => dir_name)
    machine.ssh("command" => "ls #{dir_name}").split("\n").each do |line|
      input = machine.ssh("command" => "cat #{dir_name}#{line}")
      vm = YAML.load(input)
      vm["name"] = vm["vm_name"]
      vm["ipaddress"] = vm["extra_arg"].select { |i| /^ip=/.match(i) }.first.split("=").last
      vm["ssh_port"] = 2200 + vm["ipaddress"].split("\.").last.to_i
      result << vm
    end
  end
  result
end
