description 'generates an iptables script from a template'

param :machine

on_machine do |machine, params|
  generated = @op.with_machine("localhost") do |localhost|
    template = @plugin.template_dir + '/' + :iptables.to_s + '.erb'
    localhost.process_file("file_name" => template, "bindings" => binding())            
  end
  
  target_file_name = "/root/bin/generated_fw.sh"
  machine.write_file("target_filename" => "/root/bin/generated_fw.sh", "content" => generated)
  machine.chmod("file_name" => target_file_name, "permissions" => "+x")
  
  generated
end
