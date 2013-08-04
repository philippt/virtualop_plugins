description 'lists the github repositories for a user'

github_params

param "with_service", "if set to true, we will try to find vop services in the github project (consumes time, energy and transatlantic bandwidth)", :default_value => false

mark_as_read_only

display_type :table
add_columns [ :full_name, :ssh_url, :private ]

ignore_extra_params 

execute do |params|
  result = []
  
  result = JSON.parse(@op.http_get("url" => github_url(params, '/user/repos')))
  
  if params['with_service']
    result.each do |x|
      x["full_name"] = x["owner"]["login"] + '/' + x["name"]
      # TODO branch support?
      begin
        x["has_metadata"] = @op.get_tree(params.merge({ "github_project" => x["full_name"] })).select { |y| y["path"] == ".vop" }.size > 0
        if x["has_metadata"]
          services = @op.list_services_in_github_project("github_project" => x["full_name"])
          if services.size > 0
            service = services.first
            x["installation_params"] = service["install_command_params"]
          end
        end
      rescue
        x["has_metadata"] = false
      end
    end
  end
  
  result
end