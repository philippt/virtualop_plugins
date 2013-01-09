description "writes the configured keypair onto a machine"

param :machine

on_machine do |machine, params|
  @op.with_machine("localhost") do |localhost|
    private_key = localhost.read_file("file_name" => config_string("private_key_file"))
    public_key = localhost.read_file("file_name" => config_string("public_key_file"))
    
    machine.write_file("target_filename" => "/root/.ssh/id_rsa_mrvop", "content" => private_key)
    machine.write_file("target_filename" => "/root/.ssh/id_rsa_mrvop.pub", "content" => public_key)
  end 
  
  ssh_config = read_local_template(:ssh_config, binding())
  machine.append_to_file("file_name" => "/root/.ssh/config", "content" => ssh_config)
end
