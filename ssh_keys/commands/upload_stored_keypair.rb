description "uploads one of the locally stored SSH key pairs onto a machine"

param :machine
param :keypair
param "name_suffix", "suffix to append to the standard file names for private and public keys", :default_value => ''

on_machine do |machine, params|
  details = @op.list_stored_keypairs.select { |x| x["alias"] == params["keypair"] }.first
  
  @op.with_machine("localhost") do |localhost|
    private_key = localhost.read_file("file_name" => details["private_key_file"])
    public_key = localhost.read_file("file_name" => details["public_key_file"])
    
    #filename = "/root/.ssh/id_rsa#{params['name_suffix']}"
    filename = "#{machine.home}/.ssh/id_rsa#{params['name_suffix']}"
    machine.write_file("target_filename" => filename, "content" => private_key)
    machine.write_file("target_filename" => "#{filename}.pub", "content" => public_key)
    
    machine.add_authorized_key("public_key" => public_key)
  end 
end