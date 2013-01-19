description "installs a package through the OS packaging system"

param :machine
param "name", "the name of the package to install", :mandatory => true, :allows_multiple_values => true, :default_param => true

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos", "sles"
    machine.install_rpm_package(params)    
  when "ubuntu"
    machine.install_apt_package(params)    
  end
end
