description "writes the configured keypair onto a machine"

param :machine

on_machine do |machine, params|
  machine.upload_stored_keypair("keypair" => "mrvop_ci", "name_suffix" => '_mrvop')
  
  ssh_config = read_local_template(:ssh_config, binding())
  machine.append_to_file("file_name" => "/root/.ssh/config", "content" => ssh_config)
end
