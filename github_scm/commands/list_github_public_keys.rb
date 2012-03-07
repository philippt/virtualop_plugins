description "lists the public keys associated with the current user"

github_params

add_columns [ :title, :url ]

execute do |params|
  result = []
  
  if params.has_key?('github_user') and params.has_key?('github_password')
    result = JSON.parse(@op.http_get("url" => "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com/user/keys"))
  elsif params.has_key?('github_token')
    result = JSON.parse(@op.http_get("url" => "https://api.github.com/user/repos?access_token=#{params["github_token"]}"))
  else
    raise "need either github user/password or access token to authenticate against github"
  end
  result
end
