github_params
param! 'project_data', 'data row (hash) describing a repo', :allows_multiple_values => true

mark_as_read_only

execute do |params|
  params['project_data'].map do |x|
    #x["full_name"] = x["owner"]["login"] + '/' + x["name"]
    begin
      p = { "github_project" => x["full_name"] }.merge_from(x, :git_branch)
      x["has_metadata"] = @op.get_tree(p).select { |y| y["path"] == ".vop" }.size > 0
      if x["has_metadata"]
        x["services"] = @op.services_in_github_project(p)
      end
    rescue
      x["has_metadata"] = false
    end
    x
  end
end