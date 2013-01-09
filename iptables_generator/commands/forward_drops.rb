param :machine

display_type :list

on_machine do |machine, params|
  machine.read_iptables_log.select do |line|
    /!FORWARD__DROP!/.match(line)
  end
end
