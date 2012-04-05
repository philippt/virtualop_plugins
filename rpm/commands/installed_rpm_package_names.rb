description "returns a list of rpm package names that can be copied into a kickstart script"

param :machine

display_type :list

on_machine do |machine, params|
  machine.list_installed_rpm_packages.map do |line|
    line["name"]
  end.sort
end
