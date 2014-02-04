description 'generates an iptables script from a template'

param :machine

on_machine do |machine, params|
  drop_dir = config_string('include_dropdir')
  
  @includes = {}
  
  if machine.file_exists("file_name" => drop_dir)
    %w|prerouting input forward output|.each do |phase|
      phase_dir = drop_dir + '/' + phase
      if machine.file_exists("file_name" => phase_dir)
        @includes[phase.to_sym] = "## #{phase} rules included from #{phase_dir}\n"
        machine.list_files("directory" => phase_dir).each do |file|
          @includes[phase.to_sym] += machine.read_file("file_name" => phase_dir + '/' +  file) + "\n"
        end
      end
    end
  end
  
  generated = @op.with_machine("localhost") do |localhost|
    template = @plugin.template_dir + '/' + :iptables.to_s + '.erb'
    localhost.process_file("file_name" => template, "bindings" => binding())            
  end
  
  target_file_name = "/root/bin/generated_fw.sh"
  machine.write_file("target_filename" => "/root/bin/generated_fw.sh", "content" => generated)
  machine.chmod("file_name" => target_file_name, "permissions" => "+x")
  
  generated
end
