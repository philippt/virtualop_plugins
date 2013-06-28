description "returns the nagios host objects that are configured on this nagios machine"

param :machine

mark_as_read_only

display_type :list

on_machine do |machine, params|
  os_dirs = %w|linux windows|
  
  result = []
  
  os_dirs.each do |os_dir|
    machine.list_files("directory" => [ config_string("config_root"), os_dir ].join('/')).each do |x|
      if /(.+)\.cfg$/.match x
        result << $1
      end
    end
  end
  
  result
end
