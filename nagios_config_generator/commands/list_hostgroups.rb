description "parses nagios host groups from a nagios config file"

param :machine

mark_as_read_only
display_type :hash

on_machine do |machine, params|
  result = {}
  
  hostgroup_file = [ config_string("config_root"), 'hostgroups.cfg' ].join('/')
  if machine.file_exists(hostgroup_file)
    input = machine.read_file(hostgroup_file)
    
    in_group = false
    group_name = nil
    
    input.split("\n").each do |line|
      line.chomp!
      puts ">>#{line}<<"
      next if line =~ /^#/
      
      if line =~ /define\s+hostgroup\s*{/
        in_group = true
      elsif line =~ /}/
        in_group = false
      elsif line =~ /hostgroup_name\s+(.+)/
        group_name = $1
        result[group_name] = {}
      elsif line =~ /\s*(\S+)\s+(.+)/
        result[group_name][$1] = $2 
      end
    end
        
  end
 
  result
end