description 'adds a public key to a user directory on a machine'

param :machine
#param "user", "the user account that should be used"
param "public_key", "the actual public key that should be added", :mandatory => true

on_machine do |machine, params|
  machine.mkdir("dir_name" => ".ssh", "permissions" => "700")
  unless machine.file_exists("file_name" => ".ssh/authorized_keys")
    machine.ssh_and_check_result("command" => "touch .ssh/authorized_keys")
    machine.chmod("file_name" => ".ssh/authorized_keys", "permissions" => "600")
  end
  machine.ssh_and_check_result("command" => "echo '#{params["public_key"]}' >> .ssh/authorized_keys")
end
