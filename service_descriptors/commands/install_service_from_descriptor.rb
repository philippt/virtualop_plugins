description "installs a service on a target_machine given a service descriptor, not necessarily on the same machine"

param :machine
param! :descriptor_machine
param! "descriptor", "fully qualified path where the service desriptor can be found)"
param "extra_params", "a hash of extra parameters for the service install command"

accept_extra_params

on_machine do |machine, params|
  
  descriptor_dir = params["descriptor"]
  
  parts = descriptor_dir.split("/")
  service_name = parts.last.split(".").first
  descriptor_dir = parts[0..parts.size-3].join("/")
  puts "installing service '#{service_name}' from #{descriptor_dir}"
  #if service_name == ".vop"
  #  service_name = parts[parts.size-2]
  #end
  
  @op.with_machine(params["descriptor_machine"]) do |descriptor_machine|
  
    # install dependencies
    if descriptor_machine.file_exists("file_name" => "#{descriptor_dir}/packages/github")
      
      installed_github_projects = machine.list_working_copies()
      
      descriptor_machine.ssh_and_check_result("command" => "cat #{descriptor_dir}/packages/github").split("\n").each do |line|
        next if /^#/.match(line)
        if installed_github_projects.select { |row| row["project"] == line }.size > 0
          $logger.info("github dependency #{line} already exists locally")
          next
        end
        machine.install_service_from_github("github_project" => line)
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
    
    # load as a vop plugin
    plugin_file = descriptor_dir + "/#{service_name}.plugin"
    if descriptor_machine.file_exists("file_name" => plugin_file)
      descriptor_machine.load_plugin("plugin_file_name" => plugin_file)
    end
    
    # TODO @op.flush_cache
    
    install_command_name = "#{service_name}_install"
    broker = @op.local_broker
    install_command = nil
    begin
      install_command = broker.get_command(install_command_name)
      $logger.info("found install command #{install_command.name}")
    rescue Exception => e
      $logger.info("did not find install_command #{install_command_name} : #{e.message}")
    end
    
    if install_command != nil    
      param_values = {
        "machine" => machine.name,      
        "service_root" => descriptor_dir
      }
      if params.has_key?('domain')
        param_values["domain"] = params["domain"]
      end 
      @op.comment("message" => "disabling the null check in the next line wouldn't be a good idea.")
      if params.has_key?('extra_params') && params["extra_params"] != nil 
        param_values.merge!(params["extra_params"])
      end 
      
      params_to_use = {}
      param_values.each do |k,v|
        params_to_use[k] = v if install_command.params.select do |p|
          p.name == k
        end.size > 0
      end
      #$logger.info("FOOOOO3")
      $logger.info("assembled param values : #{param_values}")
      
      request = RHCP::Request.new(install_command, params_to_use, Thread.current['broker'].context)
      response = broker.execute(request)
      
      if response.status != RHCP::Response::Status::OK
        filtered_error_detail = response.error_detail.split("\n").select do |line|
          /lib\/plugins\//.match(line)
        end.join("\n")
        $logger.error("#{response.error_text}\n#{filtered_error_detail}")
      
        raise RHCP::RhcpException.new(response.error_text)
      end
      
    end
    
    if machine.file_exists("file_name" => config_string('service_config_dir'))
      machine.hash_to_file(
        "file_name" => "#{config_string('service_config_dir')}/#{service_name}", 
        "content" => params
      )
    end
  end
  
  @op.without_cache do
    if @op.list_plugins.include? 'vop_webapp'
      machine.list_machine_tabs
      machine.list_machine_actions
    end
  end
end
