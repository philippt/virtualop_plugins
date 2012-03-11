description 'restarts a unix service'

param :machine
param :unix_service, :default_param => true

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos"
    machine.ssh_and_check_result("command" => "/etc/init.d/#{params["name"]} restart")
  when "ubuntu"
    machine.ssh_and_check_result("command" => "sudo /etc/init.d/#{params["name"]} restart")
  end
end
