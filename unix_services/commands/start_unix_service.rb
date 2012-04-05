description 'starts a unix service (something that can be started through /etc/init.d)'

param :machine
param :unix_service

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos"
    machine.ssh_and_check_result("command" => "/etc/init.d/#{params["name"]} start")
  when "ubuntu"
    machine.ssh_and_check_result("command" => "sudo /etc/init.d/#{params["name"]} start")
  end
end
