description 'generates a new firewall configuration and applies it'

param :machine

on_machine do |machine, params|
  machine.generate_iptables_script
  machine.mkdir("dir_name" => "/var/log/virtualop")
  machine.ssh_and_check_result("command" => "cd /root/bin && ./generated_fw.sh > /var/log/virtualop/iptables_generator.log")
  @op.comment("message" => "generated and executed new iptables script.")
  
  # TODO could use a service iptables save here
end  
