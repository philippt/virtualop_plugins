description "modifies the system config so that the specified service is started automatically on system startup"

param :machine
param :unix_service, :default_param => true, :allows_multiple_values => true

on_machine do |machine, params|
  params["name"].each do |name|
    machine.ssh_and_check_result("command" => "chkconfig #{name} on")
  end
end  
