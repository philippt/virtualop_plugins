description 'installs an RPM package through yum'

param :machine
param "name", "the name of the package to install", :mandatory => true, :allows_multiple_values => true, :default_param => true

on_machine do |machine, params|
  
  # filter packages that are already installed
  already_installed = machine.installed_rpm_package_names
  to_install = params["name"]
  to_install.each do |name|
    if already_installed.include? name
      to_install.delete name
    end
  end
  
  if to_install.size > 0
    machine.ssh_and_check_result("command" => "yum install -y #{to_install.join(" ")}")
    
    @op.without_cache do
      machine.list_unix_services
    end
  end
  
  to_install
end
