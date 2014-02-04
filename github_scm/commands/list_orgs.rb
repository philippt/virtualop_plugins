description "returns the organizations this github user belongs to"

github_params

add_columns [ :login, :url ]

mark_as_read_only

execute do |params|
  JSON.parse(@op.http_get("url" => github_url(params, '/user/orgs')))
end
