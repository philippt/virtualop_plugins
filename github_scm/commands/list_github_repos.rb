description 'lists the github repositories for a user'

github_params

mark_as_read_only

display_type :table
add_columns [ :full_name, :ssh_url, :private ]

ignore_extra_params 

execute do |params|
  result = []
  
  result = JSON.parse(@op.http_get("url" => github_url(params, '/user/repos')))
  
  result.each do |x|
    x["full_name"] = x["owner"]["login"] + '/' + x["name"]
    # TODO branch support?
    begin
      x["has_metadata"] = @op.get_tree(params.merge({ "github_project" => x["full_name"] })).select { |y| y["path"] == ".vop" }.size > 0
    rescue
      x["has_metadata"] = false
    end
  end
  
  result
end