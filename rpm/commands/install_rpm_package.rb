description 'installs an RPM package through yum'

param :machine
param "name", "the name of the package to install", :mandatory => true, :allows_multiple_values => true, :default_param => true

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "yum install -y #{params["name"].join(" ")}")
  
  @op.without_cache do
    machine.list_unix_services
  end
end
