description "calls the system's package manager to search for a package by name"

param :machine
param! "name", "the part of the package name to search for", :default_param => true

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos"
    machine.yum_search(params)
  when "ubuntu"
    machine.apt_search(params)
  end
end
