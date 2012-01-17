description 'returns all public keys that are permitted to login to this machine'

param :machine

display_type :list

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "cat .ssh/authorized_keys").split("\n")
end
