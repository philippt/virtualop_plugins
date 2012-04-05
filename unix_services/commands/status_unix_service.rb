description "invokes the unix service's init script to get a status check"

param :machine
param :unix_service

on_machine do |machine, params|
  command_string = "/etc/init.d/#{params["name"]} status"
  case machine.linux_distribution.split("_").first
  when "ubuntu"
    command_string = "sudo " + command_string
  end
  result = machine.ssh_extended("command" => command_string)
  result["result_code"] == 0
end
