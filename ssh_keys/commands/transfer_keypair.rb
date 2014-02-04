description "copies a stored SSH keypair onto another virtualop instance"

param :machine
param :keypair

on_machine do |machine, params|
  details = @op.list_stored_keypairs.select { |x| x["alias"] == params["keypair"] }.first
 
  %w|private public|.each do |prefix|
    file_name = details["#{prefix}_key_file"]
    machine.upload_file("local_file" => file_name, "target_file" => file_name)
  end

  # TODO that could be a simple json upload  
  machine.vop_call("command" => "store_keypair alias=#{details["alias"]} private_key_file=#{details["private_key_file"]} public_key_file=#{details["public_key_file"]}")
end