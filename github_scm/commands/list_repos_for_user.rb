description "returns the repositories of the specified github user"

github_params
param! "owner", "the github user we're talking about"

add_columns [ :full_name, :ssh_url ]

execute do |params|
  JSON.parse(@op.http_get("url" => github_url(params, "/users/#{params["owner"]}/repos")))
end
