param :machine
param! "line", "the line holding the zypper repository to install", :allows_multiple_values => true

on_machine do |machine, params|
  params["line"].each do |line|
    machine.ssh_and_check_result("command" => "zypper ar #{line}")
  end
end
