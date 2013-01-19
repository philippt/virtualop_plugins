description 'generates a new firewall configuration and applies it'

param :machine

on_machine do |machine, params|
  machine.generate_iptables_script
  machine.execute_iptables_script
end  
