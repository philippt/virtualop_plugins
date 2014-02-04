description "lists the public keys associated with the current user"

github_params

add_columns [ :title, :url ]

execute do |params|
  JSON.parse(@op.http_get("url" => github_url(params, '/user/keys')))
end
