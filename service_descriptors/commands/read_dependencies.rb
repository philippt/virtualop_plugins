param :machine
param! 'packages_folder'

display_type :hash

on_machine do |machine, params|       
  packages_dir = params['packages_folder']
  
  package_files = machine.file_exists(packages_dir) ? 
    machine.list_files("directory" => packages_dir) : []

  result = {}
  package_files.each do |name|
    lines = machine.read_lines("file_name" => "#{packages_dir}/#{name}")
    lines.each do |line|
      line.strip!
      next if /^#/.match(line)
      
      result[name.to_sym] ||= []
      result[name.to_sym] << line
    end
  end
  
  result  
end  
