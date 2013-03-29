description "triggers a configuration deployment for all configuration files on the current system"

param :spacewalk_host
param :machine

on_machine do |machine, params|
  # TODO [ugly] if there's a link called /home/mysql, delete it - spacewalk got a problem with links right now  
  if machine.file_exists("file_name" => "/home/mysql", "user" => "root")
    file_type = machine.ssh("user" => "root", "command" => "file -b /home/mysql")
    if /^symbolic link/.match(file_type)
      machine.rm("file_name" => "/home/mysql", "force" => "true", "user" => "root")
    end
  end
  
  machine.ssh("command" => "rhncfg-client get > /dev/null", "user" => "root")
end