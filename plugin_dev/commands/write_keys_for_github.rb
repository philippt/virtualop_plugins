description "writes the configured keypair onto a machine"

param :machine
param :keypair, "", :default_param => true

on_machine do |machine, params|
  @op.upload_stored_keypair(params)
  keypair = @op.list_stored_keypairs { |x| x["alias"] == params["keypair"] }.first
  
  # TODO username hardcoded in ssh_config
  
  ssh_config = read_local_template(:ssh_config, binding())
  machine.append_to_file("file_name" => "#{machine.home}/.ssh/config", "content" => ssh_config)
end
