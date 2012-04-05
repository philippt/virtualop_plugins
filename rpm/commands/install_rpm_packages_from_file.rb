description "reads a list of rpm package names from a file and installs them"

param :machine
param! "lines", "lines from a package file", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  result = []    
    
  rpms_to_install = []
  params["lines"].each do |line|
    
    next if /^#/.match(line)
    
    rpm_url = nil
    if matched = /^http.+\/(.+)\.rpm$/.match(line)
      rpm_url = line
      rpm_name = $1
      
      temp_dir = "#{machine.home}/tmp/"
      machine.mkdir("dir_name" => temp_dir) unless machine.file_exists("file_name" => temp_dir)
      machine.wget("url" => rpm_url, "target_dir" => temp_dir)
      machine.ssh_and_check_result("command" => "rpm -ihv --nosignature #{temp_dir}/#{rpm_name}*.rpm")
      
      result << rpm_name      
    else
      result += machine.install_rpm_package("name" => line)
      #rpms_to_install << line
    end
  end
  
  #result += machine.install_rpm_package("name" => rpms_to_install)
  
  result
end  


