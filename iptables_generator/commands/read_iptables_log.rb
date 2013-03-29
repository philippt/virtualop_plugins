description "just reads the content of the iptables log"

param :machine

display_type :list

mark_as_read_only

on_machine do |machine, params|
  machine.ssh("command" => "tail -n100 /var/log/iptables").split("\n")  
end
