description "invokes yum to clean all caches"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "yum clean all")
end