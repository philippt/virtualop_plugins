description "greps the current iptables log for a string"

param :machine
param! "expression", "the expression to search for"

display_type :list

mark_as_read_only

on_machine do |machine, params|
  machine.ssh("command" => "grep -e '#{params["expression"]}' /var/log/iptables")
end  
