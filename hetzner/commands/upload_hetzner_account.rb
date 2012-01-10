description "uploads hetzner configuration data from the local machine to the target machine"

param :machine
param :hetzner_account

on_machine do |machine, params|
  file_name = @plugin.hetzner_account_dropdir + '/' + params["hetzner_account"] + '.conf'
  machine.upload_file("local_file" => file_name, "target_file" => file_name)  
end
