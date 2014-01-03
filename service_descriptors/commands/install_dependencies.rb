param :machine
param! 'packages_folder'

on_machine do |machine, params|
  os = machine.machine_detail["os"]
  if os == 'linux'
    distro = machine.linux_distribution.split("_").first
  end
  
  deps = machine.read_dependencies(params)
  
  if deps[:vop]
    deps[:vop].each do |spec|
      unless /\// =~ spec
        spec = spec + '/' + spec
      end
      vop_service_name = spec.split("/").first
      $logger.info "installing vop dependency : '#{vop_service_name}'"
      # TODO version!
      unless machine.list_installed_services.include?(vop_service_name)
        machine.install_canned_service("service" => spec)
      end
    end
  end
  
  if os == 'linux'
    if %w|centos redhat|.include? distro
      machine.install_rpm_repo("repo_url" => deps[:rpm_repos]) if deps[:rpm_repos]
      machine.install_rpm_packages_from_file("lines" => deps[:rpm]) if deps[:rpm]
    elsif %w|ubuntu debian|.include? distro
      machine.install_apt_repo("repo_url" => deps[:apt_repos]) if deps[:apt_repos]
      machine.install_apt_package("name" => deps[:apt]) if deps[:apt]
    elsif distro == 'sles'
      machine.install_zypper_repo("line" => deps[:sles_repos]) if deps[:sles_repos]
      machine.machine.install_rpm_packages_from_file("lines" => deps[:rpm]) if deps[:rpm]
    end
    
    if deps[:github]
      deps[:github].each do |line|
        working_copies = machine.list_working_copies_with_projects
        found = working_copies.select { |row| row["project"] == line }
        if found.size > 0
          working_copy = found.first
          $logger.info("working copy for github dependency #{line} already exists locally")
          unless machine.list_services.map { |x| x["full_name"] }.include? line
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
          end
          machine.install_service_from_github(github_params)
        end
      end
    end
    
    if deps[:wget]
      deps[:wget].each do |line|
        machine.wget("url" => line, "target_dir" => machine.home)
      end
    end
    
    if deps[:gem]
      machine.install_gems_from_file("lines" => deps[:gem])
    end
    
    if deps[:Gemfile]
      lines = deps[:Gemfile]
      tmp_file_name = "/tmp/vop_install_service_from_descriptor_#{qualified_name}_#{@op.whoareyou}_#{Time.now.to_i.to_s}"
      machine.write_file("target_filename" => tmp_file_name, "content" => lines.join("\n"))
      machine.rvm_ssh("gem install bundler")
      machine.rvm_ssh("bundle install --gemfile=#{tmp_file_name}")
    end 
    
    
    
  end
  
end
