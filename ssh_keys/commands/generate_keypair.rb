description "generates a new key pair on the selected machine"
#
param :machine

on_machine do |machine, params|
  home = machine.home
  unless machine.file_exists("file_name" => home + '/.ssh/id_rsa')
    machine.ssh_and_check_result("command" => 'ssh-keygen -N "" -f ' + home + '/.ssh/id_rsa')
    machine.ssh_and_check_result("command" => "cd #{home}/.ssh && cat id_rsa.pub >> authorized_keys")
  end
end
