description "installs a service on a target_machine given a service descriptor, not necessarily on the same machine"

param :machine
param "descriptor_machine", "alternative location to read the descriptor from", { 
  :lookup_method => lambda do
    @op.list_machines.map do |x|
      x["name"]
    end
  end,
  :default_value => 'localhost'
}  
param :canned_service

on_machine do |machine, params|
  
  service_row = @op.list_available_services.select do |x|
    x["name"] == params["service"]
  end.first
  
  descriptor_dir = service_row["dir_name"]
  
  @op.with_machine(params["descriptor_machine"]) do |descriptor_machine|
  
    # install dependencies
    if descriptor_machine.file_exists("file_name" => "#{descriptor_dir}/packages/github")
      
      installed_github_projects = machine.list_working_copies()
      
      descriptor_machine.ssh_and_check_result("command" => "cat #{descriptor_dir}/packages/github").split("\n").each do |line|
        if installed_github_projects.select { |row| row["project"] == line }.size > 0
          $logger.info("github dependency #{line} already exists locally")
          next
        end
        machine.install_service_from_github("git_project" => line)
      end
    end  
  
    # TODO process config
    
    # install packages
    case machine.linux_distribution.split("_").first
    when "centos"  
      lines = descriptor_machine.read_file_if_exists("file_name" => "#{descriptor_dir}/packages/rpm_repos")
      machine.install_rpm_repo("repo_url" => lines) unless lines.size == 0
      
      lines = descriptor_machine.read_file_if_exists("file_name" => "#{descriptor_dir}/packages/rpm")    
      machine.install_rpm_packages_from_file("lines" => lines) unless lines.size == 0
    when "ubuntu"
      lines = descriptor_machine.read_file_if_exists("file_name" => "#{descriptor_dir}/packages/apt_repos")    
      machine.install_apt_repo("repo_url" => lines) unless lines.size == 0
      
      lines = descriptor_machine.read_file_if_exists("file_name" => "#{descriptor_dir}/packages/apt")    
      machine.install_apt_package("name" => lines) unless lines.size == 0
    end
    
    lines = descriptor_machine.read_file_if_exists("file_name" => "#{descriptor_dir}/packages/gem")    
    machine.install_gems_from_file("lines" => lines) unless lines.size == 0
  end
end
