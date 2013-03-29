description "generates a new key pair on the selected machine"
#
param :machine
param "ssh_dir", "the ssh configuration directory (defaults to $HOME/.ssh)"

on_machine do |machine, params|
  ssh_dir = params.has_key?('ssh_dir') ? params["ssh_dir"] : machine.home + '/.ssh'
  private_keyfile = ssh_dir + '/id_rsa'
  unless machine.file_exists("file_name" => private_keyfile)
    machine.mkdir("dir_name" => ssh_dir) 
    machine.ssh("command" => 'ssh-keygen -N "" -f ' + private_keyfile)
    machine.ssh("command" => "cd #{ssh_dir} && cat id_rsa.pub >> authorized_keys")
  end
  @op.without_cache do
    machine.file_exists("file_name" => private_keyfile)
  end
end
