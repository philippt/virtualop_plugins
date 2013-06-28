description "invokes the unix service's init script to get a status check"

param :machine
param :unix_service

on_machine do |machine, params|
  command_string = "sudo /etc/init.d/#{params["name"]} status"
  result = machine.ssh_extended("command" => command_string, "request_pty" => "true")
  result["result_code"] == 0
end
