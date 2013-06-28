description 'starts a unix service (something that can be started through /etc/init.d)'

param :machine
param :unix_service

on_machine do |machine, params|
  machine.ssh("command" => "sudo /etc/init.d/#{params["name"]} start", "request_pty" => "true")
end
