description 'restarts a unix service'

param :machine
param :unix_service

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "/etc/init.d/#{params["name"]} restart")
end
