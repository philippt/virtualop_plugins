description "uploads hetzner configuration data from the local machine to the target machine"

param :machine
param :hetzner_account

on_machine do |machine, params|
  drop_dir = hetzner_account_dropdir
  file_name = "#{drop_dir}/#{params["hetzner_account"]}.conf"
  machine.upload_file("local_file" => file_name, "target_file" => file_name)  
end
