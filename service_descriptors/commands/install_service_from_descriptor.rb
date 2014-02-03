description "installs a service on a target_machine given a service descriptor, not necessarily on the same machine"

param :machine
param! :descriptor_machine
param! "descriptor", "fully qualified path where the service descriptor can be found)"
param "service_root", "path where the service should be installed"
param "version", "version information about the service to be installed"

accept_extra_params

on_machine do |machine, params, request|
  
  parts = params["descriptor"].split("/")
  descriptor_dir = parts[0..parts.size-3].join("/")
  
  service_name = parts.last.split(".").first
  qualified_name = service_name
  
  $logger.info("installing service '#{service_name}' from #{descriptor_dir}")
  $logger.info("service root : #{params["service_root"]}") if params.has_key? "service_root"
  
  old_user = nil
  key = "machine_user.#{params["machine"]}"
  if request.context.cookies.has_key?(key)
    old_user = request.context.cookies[key]
  end
  user_set = false
  
  begin
  @op.with_machine(params["descriptor_machine"]) do |descriptor_machine|
    
    dotvop_dir = "#{descriptor_dir}/.vop"
    if descriptor_machine.file_exists("file_name" => dotvop_dir)
      @op.comment("message" => "found descriptor dir #{dotvop_dir}")
      descriptor_dir = dotvop_dir 
    end
    
    descriptor_file_name = params["descriptor"]
    if descriptor_machine.file_exists descriptor_file_name
      descriptor = descriptor_machine.read_service_descriptor("file_name" => descriptor_file_name)
    end
    
    if descriptor.has_key?('user')
      user_name = descriptor['user']
      if user_name == old_user
        @op.comment "already in user context #{old_user}, not switching"
      else
        machine.init_system_user('user' => user_name)
        
        machine.set_machine_user(user_name)
        user_set = true
        # TODO #performance
        @op.flush_cache if @op.list_plugins.include? 'memcached_plugin'
      end
    end
    
    descriptor["dependencies"].each do |dependency|
      case dependency["type"]
      when "vop"
        # TODO support subservices properly
        unless machine.list_installed_services.include? dependency["name"]
          p = {
            "service" => dependency["name"],
            "extra_params" => {}
          }            
          dependency.each do |k,v|
            p[k] = v unless %w|name type|.include? k
            p["extra_params"][k] = v
          end
          machine.install_canned_service(p)
        end
      else
        raise "unhandled dependency type #{dependency["type"]}"
      end  
    end
    
    dotvop_content = descriptor_machine.list_files("directory" => descriptor_dir)
    plugin_names = dotvop_content.select do |file|
      /\.plugin$/.match(file)
    end.map { |x| x.split(".").first }
    raise "found more than one plugin file in #{dotvop_dir}" if plugin_names.size > 1
    raise "could not find plugin file in #{dotvop_dir}" if plugin_names.size == 0
    plugin_name = plugin_names.first
    @op.comment("plugin name : #{plugin_name}")
    
    if plugin_name
      qualified_name = plugin_name + '/' + service_name
    end
  
    if plugin_name == service_name
        
      package_dir = "#{descriptor_dir}/packages"
      
      package_files = descriptor_machine.file_exists("file_name" => package_dir) ? descriptor_machine.list_files("directory" => package_dir) : []
      
      if package_files.include? "vop"
        lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/vop")
        lines.each do |service_spec|
          service_spec.strip!
          next if /^#/.match(service_spec)
          unless /\//.match(service_spec)
            puts "service_spec : '#{service_spec}'"
            service_spec += '/' + service_spec
          end
          vop_service_name = service_spec.split("/").first
          # TODO version
          puts "installing vop dependency : '#{vop_service_name}'"
          machine.install_canned_service("service" => service_spec) unless machine.list_installed_services.include?(vop_service_name)
        end    
      end
      
      if machine.machine_detail["os"] == "windows"
      
      else
        case machine.linux_distribution.split("_").first
        when "centos"          
          if package_files.include? "rpm_repos"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/rpm_repos")
            machine.install_rpm_repo("repo_url" => lines) unless lines.size == 0
          end  
          
          if package_files.include? "rpm"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/rpm")    
            machine.install_rpm_packages_from_file("lines" => lines) unless lines.size == 0
          end
        when "ubuntu"
          if package_files.include? "apt_repos"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/apt_repos")    
            machine.install_apt_repo("repo_url" => lines) unless lines.size == 0
          end
          
          if package_files.include? "apt"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/apt")    
            machine.install_apt_package("name" => lines) unless lines.size == 0
          end
        when "sles"
          if package_files.include? "sles_repos"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/sles_repos").select { |x| ! /^#/.match(x) }
            machine.install_zypper_repo("line" => lines) unless lines.size == 0
          end

          if package_files.include? "sles"
            lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/sles").select { |x| ! /^#/.match(x) }
            machine.install_rpm_packages_from_file("lines" => lines) unless lines.size == 0
          end
        end

        # -> non-distribution specific linux
        if package_files.include? "github"
          working_copies = machine.list_working_copies_with_projects
  
          descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/github").each do |line|
            next if /^#/.match(line)
            found = working_copies.select { |row| row["project"] == line }
            if found.size > 0
              working_copy = found.first
              $logger.info("working copy for github dependency #{line} already exists locally")
              if not machine.list_services.map { |x| x["full_name"] }.include? line
                machine.install_service_from_working_copy("working_copy" => working_copy["name"], "service" => working_copy["name"])
              end
            else              
              github_params = {"github_project" => line}
              # inherit git_branch if the dependency project has a branch or tag by that name
              if params.has_key?("extra_params") && params["extra_params"]
                if params["extra_params"].has_key?("git_branch")
                  inherit_branch = false
                  if has_github_params(params)
                    trees =  @op.list_branches("github_project" => line) + 
                      @op.list_tags("github_project" => line).map do |x|
                        x["name"]
                      end
                    if trees.include? params["extra_params"]["git_branch"]
                      inherit_branch = true 
                    end
                  end
                  
                  if inherit_branch
                    github_params["git_branch"] = params["extra_params"]["git_branch"]
                  end
                end
                #github_params = github_params.merge_from(params["extra_params"], :git_branch, :git_tag)
              end
              machine.install_service_from_github(github_params)
            end
          end
        end
        
        if package_files.include? "wget"
          descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/wget").each do |line|
            next if /^#/ =~ line
            machine.wget("url" => line, "target_dir" => machine.home)           
          end
        end
        
        if package_files.include? "gem"
          lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/gem")    
          machine.install_gems_from_file("lines" => lines) unless lines.size == 0          
        end
        
        if package_files.include? "Gemfile"
          lines = descriptor_machine.read_lines("file_name" => "#{descriptor_dir}/packages/Gemfile")
          tmp_file_name = "/tmp/vop_install_service_from_descriptor_#{qualified_name}_#{@op.whoareyou}_#{Time.now.to_i.to_s}"
          machine.write_file("target_filename" => tmp_file_name, "content" => lines.join("\n"))
          
          machine.rvm_ssh("gem install bundler")
          machine.rvm_ssh("bundle install --gemfile=#{tmp_file_name}")
          
          # TODO [rpm]
          #machine.as_user('root') do |root|
          #  root.ssh("gem install bundler")
          #  root.ssh("bundle install --gemfile=#{tmp_file_name}")
          #end
          #machine.rvm_ssh("gem install bundler")
        end
        
        if params.has_key?("service_root") && params["service_root"] != ''
          gemfile_location = "#{params["service_root"]}/Gemfile"
          if machine.file_exists(gemfile_location)
            # TODO [rpm]
            #machine.as_user('root') do |root|
            #  root.ssh("gem install bundler")
            #end
            machine.rvm_ssh("gem install bundler")        
            machine.rvm_ssh("cd #{params['service_root']} && bundle install --gemfile=#{gemfile_location}")
          end
        end
      end # linux
      
      # TODO uranos
      
    end
    
    @op.comment "installed dependencies for #{plugin_name}"
    
    # load as a vop plugin
    if ((plugin_name != nil) and (not @op.list_plugins.include?(plugin_name)))
      plugin_file = descriptor_dir + "/#{plugin_name}.plugin"
      if descriptor_machine.file_exists("file_name" => plugin_file)
        descriptor_machine.load_plugin("plugin_file_name" => plugin_file)
      end
    end
    
    # TODO process config
    
    install_command_name = "#{service_name}_install"
    #broker = @op.local_broker
    broker = Thread.current['broker']
    install_command = nil
    begin
      install_command = broker.get_command(install_command_name)
      $logger.info("found install command #{install_command.name}")
    rescue Exception => e
      $logger.debug("did not find install_command #{install_command_name} : #{e.message}")
    end
    
    if install_command != nil    
      param_values = params.clone()
      
      @op.comment("message" => "disabling the null check in the next line wouldn't be a good idea.")
      if params.has_key?('extra_params') && params["extra_params"] != nil #&& params["extra_params"].class == Hash
        param_values.merge!(params["extra_params"])
      end
      
      $logger.info("available param values: \n#{param_values.map { |k,v| "\t#{k}\t#{v}" }.join("\n")}")
       
      params_to_use = { }
      param_values.each do |k,v|
        params_to_use[k] = v if install_command.params.select do |p|
          p.name == k
        end.size > 0
      end
      $logger.info("params_to_use : \n#{params_to_use.map { |k,v| "\t#{k}\t#{v}" }.join("\n")}")
      
      @op.comment "invoking #{install_command.name}..."
      begin
        @op.send(install_command.name.to_sym, params_to_use)
      rescue => detail
        @op.comment("message" => "got a problem while executing install command '#{install_command.name}' : #{detail.message}")
        raise detail
      end
    end

    # TODO this should not be necessary
    @op.flush_cache
    
    if machine.machine_detail["os"] == "windows"
      config_dir = '.vop/services'
      if machine.win_file_exists("file_name" => config_dir)
        machine.win_write_file("target_filename" => "#{config_dir}/#{qualified_name}", "content" => params.to_yaml)
      end    
    else
      if machine.file_exists("file_name" => machine.config_dir)
        machine.hash_to_file(
          "file_name" => "#{machine.config_dir}/#{qualified_name}", 
          "content" => params
        )
      end
    end
  end
  
  @op.comment "installation complete for #{service_name}, gonna invalidate and post-process"
  
  service = nil
  @op.without_cache do
    machine.list_installed_services
    machine.list_services 
    service = machine.service_details("service" => qualified_name)
    machine.status_services
  end
  
  raise "could not find service information after installation, service is nil" if service == nil
    
  if service.has_key?("post_installation")
    details = nil
    # TODO [optimization] would be helpful if we could just load the details without cache without reloading the lookups
    @op.without_cache do
      details = machine.service_details("service" => service["full_name"])
      if details.has_key?("post_installation")
        begin
          details["post_installation"].call(machine, params)
        rescue => detail
          raise "problem in post_installation block for service #{service["name"]} on #{params["machine"]} : #{detail.message}"
        end
      else
        @op.comment "post-installation key found in service details, but could not reload post_installation block for execution. weird."
      end
    end
  end
  
  @op.post_process_service_installation(params.merge("service" => qualified_name))
  
  if service.has_key?("outgoing_tcp") && service["outgoing_tcp"] != nil && service["outgoing_tcp"].is_a?(Array)
    service["outgoing_tcp"].each do |outgoing|
      case outgoing
      when "all_destinations"
        host_name = machine.name.split('.')[1..10].join('.')
        @op.with_machine(host_name) do |host|
          host.add_forward_include(
            "source_machine" => machine.name,
            "service" => service_name,
            "content" => "iptables -A FORWARD -s #{machine.ipaddress} -p tcp -m state --state NEW -j ACCEPT"
          )
          #host.generate_and_diff_iptables()  # TODO needs 'differ' gem
          host.generate_and_execute_iptables_script()
        end
      else
        raise "unknown destination #{outgoing} in service #{service_name}"
      end
    end
  end
  
  %w|tcp udp|.each do |protocol|
    endpoint_name = "#{protocol}_endpoint"
    if service.has_key?(endpoint_name)
      service[endpoint_name].each do |endpoint|
        port = endpoint
        host_name = machine.name.split('.')[1..10].join('.')
        
        @op.configure_endpoint( 
          "machine" => host_name, 
          "source_machine" => machine.name, "service" => service["name"],
          "protocol" => protocol, "port" => port 
        )
      end
    end
  end
  
  if service.has_key?("apache_config")
    unless params.has_key?("extra_params") and params["extra_params"].has_key?("domain")
      raise "apache_config found for service #{service["name"]}, but no domain parameter is present. don't know where to publish, please give me a domain param"
    end
    
    domain = params["extra_params"]["domain"]
    if domain.is_a?(Array)
      domain = domain.first
    end      
    machine.install_canned_service("service" => "apache/apache")
    
    template_name = service["apache_config"]
    template_path = descriptor_dir + '/templates/' + template_name.to_s + '.erb'
    puts "template for apache config : #{template_path}"
    
    config_path = "#{machine.apache_generated_conf_dir}/#{domain}.conf"
    puts "apache config will be written into #{config_path}"
    
    generated = @op.with_machine(params["descriptor_machine"]) do |descriptor_machine|
      descriptor_machine.process_file(
        "file_name" => template_path,
        "bindings" => binding() 
      )
    end
    puts "generated : #{generated}"
    machine.as_user('root') do |root|
      root.write_file("target_filename" => config_path, "content" => generated)
    end
    
    machine.restart_service 'apache/apache'
    machine.configure_reverse_proxy("domain" => domain) if machine.proxy
  end    
  
  if service["is_startable"]
    machine.start_service("service" => service["full_name"])
  end
  
  if service.has_key?("post_first_start")
    details = nil
    # TODO [optimization] would be helpful if we could just load the details without cache without reloading the lookups
    @op.without_cache do
      details = machine.service_details("service" => service["full_name"])
      if details['post_first_start']
        begin
          details['post_first_start'].call(machine, params)
        rescue => detail
          raise "problem in post_first_start block for service #{service["name"]} on #{params["machine"]} : #{detail.message}"
        end
      else
        @op.comment "post_first_start key found in service details, but could not reload post_first_start block for execution. weird."
      end
    end
  end
  
  #@op.post_process_service_first_start(params.merge("service" => qualified_name))
  
  ensure
    if user_set
      # TODO remove sudo permissions?
      machine.unset_machine_user
    end
    if old_user
      machine.set_machine_user(old_user)
    end
  end
  
  @op.comment "post-processing complete for installation of service #{service_name}"
end
