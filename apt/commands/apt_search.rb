description "searches for a package by name"

param :machine
param! "name", "name or name fragment of the package to search for"

on_machine do |machine, params|
  machine.ssh("command" => "sudo apt-cache search #{params["name"]}")
end