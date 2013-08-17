description "creates a working copy of a github project on a machine and installs the project"

github_params

param :machine
param! :github_project
param :git_branch
param :git_tag

param "service_root"

accept_extra_params

execute do |params, request|
  @op.with_machine(params["machine"]) do |machine|
    project_name = params["github_project"].split("/").last
    
    # read the service descriptor through github first
    p = params.clone
    p.delete("machine")
    descriptor = @op.list_services_in_github_project(p).select do |x|
      x["name"] == project_name
    end.first
    
    old_user = nil
    key = "machine_user.#{params["machine"]}"
    if request.context.cookies.has_key?(key)
      old_user = request.context.cookies[key]
    end
    user_set = false
    if descriptor
      pp descriptor
      
      if descriptor.has_key?('user')
        user_name = descriptor['user']
        unless machine.list_system_users.select { |x| x['name'] == user_name }.size > 0
          machine.add_system_user user_name
        end
        # TODO don't do this by default and don't do it more than once
        begin
          machine.grant_sudo_all user_name
        rescue
          # TODO handle
        end
        
        # TODO do we really want to do this just for installing one service from github?
        machine.chown("file_name" => "/etc/vop/installed_services", "ownership" => "#{user_name}:")
        
        machine.set_machine_user(user_name)
        user_set = true
        @op.flush_cache
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
      
      @op.github_clone({"directory" => service_root}.merge_from(
        params, :machine, :github_project, :git_branch, :git_tag, :github_user, :github_password, :github_token
      ))
      
      # TODO remove
      machine.list_services_in_working_copies
      
      params["working_copy"] = project_name # TODO is that a good idea? (used to be the path)
      params["service"] = project_name
      
      if params.has_key?('extra_params')
        params["extra_params"].each do |k,v|
          params[k] = v
        end
      end
      
      params["version"] = {}.merge_from params, :github_project, :git_branch, :git_tag
      
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
