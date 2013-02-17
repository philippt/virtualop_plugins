description 'restarts a unix service'

param :machine
param :unix_service, { :default_param => true, :allows_multiple_values => true }

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos","sles"
    params["name"].each do |name|
      machine.ssh_and_check_result("command" => "/etc/init.d/#{name} restart")
    end
  when "ubuntu"
    params["name"].each do |name|
      machine.ssh_and_check_result("command" => "sudo /etc/init.d/#{name} restart")
    end
  end
end
