description 'invokes "rpm" to import a new key'

param :machine
param "url", "http url where the key should be downloaded from", :mandatory => true

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rpm --import #{params["url"]}")
end
