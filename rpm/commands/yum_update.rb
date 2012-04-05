description 'invokes yum update to upgrade all installed system packages'

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "yum -y update 2>&1 > /var/log/yum_update.log")
end
