description "modifies the local ssh configuration so that no host key checks are performed"

param :machine
param "home_dir", "the home directory into which the ssh configuration should be written"

on_machine do |machine, params|
  params["home_dir"] ||= machine.home
  file_name = params["home_dir"] + '/.ssh/config'
  
  machine.append_to_file("file_name" => file_name, "content" => 'StrictHostKeyChecking no')
  # TODO do we need this line?
  #machine.append_to_file("file_name" => file_name, "content" => 'UserKnownHostsFile /dev/null')
end
