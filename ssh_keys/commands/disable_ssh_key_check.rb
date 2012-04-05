description "modifies the local ssh configuration so that no host key checks are performed"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => 'echo "StrictHostKeyChecking no" >> ' + machine.home + '/.ssh/config')
  machine.ssh_and_check_result("command" => 'echo "UserKnownHostsFile /dev/null" >> ' + machine.home + '/.ssh/config')
end