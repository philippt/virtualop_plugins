description 'invokes yum to invoke a group of packages'

param :machine
param "group_name", "the group name or string (may contain wildcards)", :mandatory => true

on_machine do |machine, params|
  machine.ssh("command" => "yum -y groupinstall \"#{params["group_name"]}\"")
end
