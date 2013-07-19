description "calls the system's package manager to search for a package by name"

param :machine
param! "name", "the part of the package name to search for", :default_param => true

as_root do |machine, params|
  distro = machine.linux_distribution.split("_").first
  case distro
  when "centos"
    machine.yum_search(params)
  when "ubuntu"
    machine.apt_search(params)
  when "sles"
    machine.zypper_search(params)
  else
    raise "don't know how to search for packages on #{distro}"
  end
end
