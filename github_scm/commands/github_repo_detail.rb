github_params
param! :github_project
param :git_branch
param 'with_install_command', '', :default_value => false

#add_columns [ :full_name ]

display_type :hash

#mark_as_read_only
#no_cache

execute do |params|
  org_name = params['github_project'].split('/').first
  rows = org_name == @op.github_user(params)['login'] ?
    @op.list_github_repos(params) :
    @op.list_repos_for_org(params.merge('org' => org_name))
  row = rows.select { |x| x['full_name'] == params['github_project'] }.first
  unless row
    #raise "sanity check failed: github project #{params['github_project']} not found in user or organisation repos"
    row = {
      'full_name' => params['github_project']
    } 
  end
  
  row.merge_from params, :git_branch
  result = @op.inspect_github_repos('project_data' => row).first

  if params['with_install_command']
    services = @op.list_services_in_github_project('github_project' => params['github_project'])
    
    if result && result['services'] && result['services'].size > 0
      # actually, x['full_name'] does not correspond to service_name
      #service_name = result['services'].first
      #service = services.select { |x| x['full_name'] == service_name }.first
      service = services.first
      begin
        if service.has_key?('install_command_name') and service['install_command_name'] != nil
          result['install_command'] = @op.broker.get_command(service["install_command_name"])
        end
      rescue RHCP::RhcpException => e
        $logger.warn("cannot load install command for service #{service["name"]} : #{e}")
        raise e
      end
    end
  end
  
  result  
end
