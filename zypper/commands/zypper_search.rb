description "searches for a package using zypper"

param :machine
param! "name", "the part of the package name to search for", :default_param => true

on_machine do |machine, params|
  machine.ssh("command" => "zypper search #{params["name"]}")
end
