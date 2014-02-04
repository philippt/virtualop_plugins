description 'executes the generated iptables script'

param :machine

on_machine do |machine, params|
  machine.mkdir("dir_name" => "/var/log/virtualop")
  machine.ssh("command" => "cd /root/bin && ./generated_fw.sh > /var/log/virtualop/iptables_generator.log")
  @op.comment("message" => "executed new iptables script.")
  
  generated_file = "/root/bin/generated_fw.sh"
  backup_file = generated_file + ".bak"
  machine.ssh("command" => "cp #{generated_file} #{backup_file}")
  
  # TODO could use a service iptables save here
end  