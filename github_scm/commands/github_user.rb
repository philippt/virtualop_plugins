description "retrieves information about the current user through the github API"

github_params

display_type :hash

execute do |params|
  JSON.parse(@op.http_get("url" => github_url(params, '/user')))
end  
