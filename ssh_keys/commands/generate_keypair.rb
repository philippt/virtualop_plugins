description "generates a new key pair on the selected machine"
#
param :machine

on_machine do |machine, params|
  private_keyfile = machine.home + '/.ssh/id_rsa'
  unless machine.file_exists("file_name" => private_keyfile)
    machine.ssh_and_check_result("command" => 'ssh-keygen -N "" -f ' + private_keyfile)
    machine.ssh_and_check_result("command" => "cd #{home}/.ssh && cat id_rsa.pub >> authorized_keys")
  end
  @op.without_cache do
    machine.file_exists("file_name" => private_keyfile)
  end
end
