description 'invokes "rpm" to import a new key'

param :machine
param! "url", "http url where the key should be downloaded from"

on_machine do |machine, params|
  machine.ssh("command" => "sudo rpm --import #{params["url"]}", "request_pty" => "true")
end
