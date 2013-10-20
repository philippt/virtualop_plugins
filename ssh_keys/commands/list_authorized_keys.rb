description 'returns all public keys that are permitted to login to this machine'

param :machine

display_type :list

on_machine do |machine, params|
  machine.read_lines("file_name" => ".ssh/authorized_keys") || []
end
