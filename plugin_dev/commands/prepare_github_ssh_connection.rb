description "given a stored SSH keypair, this will prepare a machine's configuration to connect as the user via ssh to github"

github_params

param :machine
param :keypair

on_machine do |machine, params|
  machine.upload_stored_keypair("keypair" => params["keypair"])
  keypair = @op.list_stored_keypairs { |x| x["alias"] == params["keypair"] }.first
  
  puts "params"
  pp params
  p = {}.merge_from(params, :github_user, :github_password, :github_token)
  puts "p"
  pp p
  github_user = @op.github_user(p)
  
  machine.ssh "git config --global user.email '#{github_user["email"]}'"
  machine.ssh "git config --global user.name '#{github_user["name"]}'"
  
  ssh_config = read_local_template(:ssh_config, binding())
  machine.append_to_file("file_name" => "#{machine.home}/.ssh/config", "content" => ssh_config)
  machine.disable_ssh_key_check
end
