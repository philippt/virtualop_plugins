description "reads a list of rpm package names from a file and installs them"

param :machine
param! "lines", "lines from a package file", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  result = []    
    
  params["lines"].each do |line|
    next if /^#/.match(line)
    
    line.chomp!
    
    rpm_url = nil
    if matched = /^http.+\/(.+?)-(\d+.+)\.rpm$/.match(line)
      rpm_url = line
      rpm_name = $1
      rpm_version = $2
    
      unless machine.installed_rpm_package_names.include? rpm_name  
        temp_dir = "#{machine.home}/tmp/"
        machine.mkdir("dir_name" => temp_dir) unless machine.file_exists("file_name" => temp_dir)
        machine.wget("url" => rpm_url, "target_dir" => temp_dir)
        machine.install_rpm_package "#{temp_dir}/#{rpm_name}-#{rpm_version}*.rpm"
        
        result << rpm_name      
      end
    else
      result += machine.install_rpm_package("name" => line)
    end
  end
  
  result
end  


