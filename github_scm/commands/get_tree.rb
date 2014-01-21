description "retrieves raw data for a github project"

github_params
param! :github_project
param :git_branch
param "recursive", "set to '1' to fetch recursively"
param 'path'

#mark_as_read_only

add_columns [ :type, :sha, :path ]

execute do |params|
  params["revision"] = params.has_key?("git_branch") ? params["git_branch"] : 'master'
  recursive = params.has_key?("recursive") ? 'recursive=1&' : ''
  url = "https://api.github.com/repos/#{params["github_project"]}/git/trees/#{params["revision"]}?#{recursive}access_token=#{params["github_token"]}"
  
  result = JSON.parse(@op.http_get("url" => url))
  result["tree"].clone if result["tree"]
end
