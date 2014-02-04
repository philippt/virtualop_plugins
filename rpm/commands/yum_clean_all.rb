description "invokes yum to clean all caches"

param :machine

on_machine do |machine, params|
  machine.ssh("command" => "yum clean all")
end