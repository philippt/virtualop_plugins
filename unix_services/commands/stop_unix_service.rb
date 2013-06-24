description 'stop a unix service (something that can be started through /etc/init.d)'

param :machine
param :unix_service

on_machine do |machine, params|
  command_string = "sudo /etc/init.d/#{params["name"]} stop"
  machine.ssh("command" => command_string, "request_pty" => "true")
end
