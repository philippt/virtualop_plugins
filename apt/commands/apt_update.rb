description "performs apt-update to update the apt package index; no packages are updated"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "sudo apt-get update -y")
end

