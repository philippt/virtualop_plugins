description "creates a working copy of a github project on a machine and installs the project"

github_params

param :machine
param! :github_project
param :git_branch
#param :git_tag

param "service_root"

param "force", "set (to any value) if you want to override existing target directories"

accept_extra_params

execute do |params, request|
  @op.with_machine(params["machine"]) do |machine|
    project_name = params["github_project"].split("/").last
    
    old_user = nil
    user_set = false
    if has_github_params(params)
      # read the service descriptor through github first
      p = params.clone
      p.delete("machine")      
      descriptor = @op.list_services_in_github_project(p).select do |x|
        x["name"] == project_name
      end.first
      
      key = "machine_user.#{params["machine"]}"
      if request.context.cookies.has_key?(key)
        old_user = request.context.cookies[key]
      end
      if descriptor
        if descriptor.has_key?('user') 
          user_name = descriptor['user']
          if user_name == old_user
            @op.comment "already in user context #{old_user}, not switching"
          else
            machine.init_system_user('user' => user_name)
            
            machine.set_machine_user(user_name)
            user_set = true
            @op.flush_cache
          end
        end
      end
    end
    
    begin
      service_root = nil  
      if params.has_key?("service_root") 
        service_root = params["service_root"]
      elsif params.has_key?('extra_params') and params['extra_params'].has_key?('service_root')
        service_root = params['extra_params']['service_root']
      else 
        service_root = "#{machine.home}/#{project_name}"
      
        if params.has_key?('extra_params') and params["extra_params"].has_key?("service_root")
          service_root = params['extra_params']['service_root']
        elsif params.has_key?('extra_params') and params["extra_params"].has_key?("domain")
          service_root = "/var/www/#{project_name}"
        end
      end
      if service_root.is_a? Array
        service_root = service_root.first
      end
      
      @op.github_clone({"directory" => service_root}.merge_from(
        params, :machine, :github_project, :git_branch, :force, 
          :github_user, :github_password, :github_token
      )) unless machine.file_exists(service_root)
      
      # TODO remove
      machine.list_services_in_working_copies
      
      params["working_copy"] = project_name # TODO is that a good idea? (used to be the path)
      params["service"] = project_name
      
      if params.has_key?('extra_params')
        params["extra_params"].each do |k,v|
          params[k] = v
        end
        params["extra_params"].merge_from params, :github_project, :git_branch, :git_tag
      end
      
      machine.install_service_from_working_copy(params)
    ensure
      if user_set
        # TODO remove sudo permissions?
        machine.unset_machine_user
      end
      if old_user
        machine.set_machine_user(old_user)
      end
    end
  end
end
