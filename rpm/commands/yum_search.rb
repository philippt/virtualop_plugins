description "searches for a package using yum"

param :machine
param! "name", "the part of the package name to search for", :default_param => true

on_machine do |machine, params|
  machine.ssh("command" => "yum search #{params["name"]}")
end
