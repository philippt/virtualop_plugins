description 'starts a unix service (something that can be started through /etc/init.d)'

param :machine
param :unix_service

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "/etc/init.d/#{params["name"]} start")
end
