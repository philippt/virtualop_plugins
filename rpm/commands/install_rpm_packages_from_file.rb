description "reads a list of rpm package names from a file and installs them"

param :machine
param! "lines", "lines from a package file", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  result = []
  
  already_installed = machine.installed_rpm_package_names
    
  params["lines"].each do |line|
    
    rpm_name = line
    
    rpm_url = nil
    if matched = /^http.+\/(.+)\.rpm$/.match(line)
      rpm_url = line
      rpm_name = $1
    end
    
    begin
      #if matched = /^(.+?)-(\d+.+)/.match(rpm_name)
        #rpm_name = matched.captures.first
        
      existing = already_installed.select do |candidate|
        /^#{rpm_name}-/.match(candidate)
      end
      if existing.size > 0
        $logger.info("package #{rpm_name} already installed.")
        next  
      end
    rescue
      $logger.warn("could not check if the RPM #{rpm_name} is already installed - gonna install it to be on the safe side (tm).")
    end    
    
    if rpm_url != nil   
      temp_dir = "#{machine.home}/tmp/"
      machine.mkdir("dir_name" => temp_dir) unless machine.file_exists("file_name" => temp_dir)
      machine.wget("url" => rpm_url, "target_dir" => temp_dir)
      machine.ssh_and_check_result("command" => "rpm -ihv --nosignature #{temp_dir}/#{rpm_name}*.rpm")      
    else
      machine.install_rpm_package("name" => rpm_name)
    end
        
    result << rpm_name
  end
  result
end  


