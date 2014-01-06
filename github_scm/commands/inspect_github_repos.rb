github_params
param! 'project_data', 'data row (hash) describing a repo', :allows_multiple_values => true

mark_as_read_only

execute do |params|
  params['project_data'].map do |x|
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
        x['services'] = services
      end
    rescue
      x["has_metadata"] = false
    end
    x
  end
end