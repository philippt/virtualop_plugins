description 'adds a public key to a user directory on a machine so that it is authorized to login'

param :machine
param! "public_key", "the actual public key that should be added", :default_param => true

on_machine do |machine, params|
  machine.mkdir("dir_name" => ".ssh", "permissions" => "700")
  unless machine.file_exists("file_name" => ".ssh/authorized_keys")
    machine.ssh("command" => "touch .ssh/authorized_keys")
    machine.chmod("file_name" => ".ssh/authorized_keys", "permissions" => "600")
  end
  machine.ssh("command" => "echo \"#{params["public_key"]}\" >> .ssh/authorized_keys")
end
