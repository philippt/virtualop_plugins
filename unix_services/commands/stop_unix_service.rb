description 'stop a unix service (something that can be started through /etc/init.d)'

param :machine
param :unix_service

on_machine do |machine, params|
  command_string = "/etc/init.d/#{params["name"]} stop"
  case machine.linux_distribution.split("_").first
  when "ubuntu"
    command_string = "sudo " + command_string
  end
  machine.ssh_and_check_result("command" => command_string)
end
