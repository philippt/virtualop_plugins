description "uploads one of the locally stored SSH key pairs onto a machine"

param :machine
param :keypair

on_machine do |machine, params|
  details = @op.list_stored_keypairs.select { |x| x["alias"] == params["keypair"] }.first
  
  name_suffix = ''
  
  @op.with_machine("localhost") do |localhost|
    private_key = localhost.read_file("file_name" => details["private_key_file"])
    public_key = localhost.read_file("file_name" => details["public_key_file"])
    
    machine.write_file("target_filename" => "/root/.ssh/id_rsa#{name_suffix}", "content" => private_key)
    machine.write_file("target_filename" => "/root/.ssh/id_rsa#{name_suffix}.pub", "content" => public_key)
    
    machine.add_authorized_key("public_key" => public_key)
  end 
end