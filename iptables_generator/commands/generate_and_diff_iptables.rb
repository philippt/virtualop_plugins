description 'generates a new firewall configuration and shows the difference to the currently active one'

param :machine

on_machine do |machine, params|
  generated_file = "/root/bin/generated_fw.sh"
  backup_file = generated_file + ".bak"
  
  unless machine.file_exists("file_name" => backup_file)
    machine.ssh("command" => "cp #{generated_file} #{backup_file}")
  end    
  
  machine.generate_iptables_script
  @op.comment("message" => "generated new iptables script.")
  
  @op.without_cache do
    new_file = machine.read_file("file_name" => "/root/bin/generated_fw.sh")
    old_file = machine.read_file("file_name" => "/root/bin/generated_fw.sh.bak")
    require 'differ'
    require 'differ/string'
    Differ.format = :color
    old_file - new_file
  end
end  
