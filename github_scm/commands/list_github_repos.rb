description 'lists the github repositories for a user'

param "github_user", "the github user to use"
param "github_password", "the password that should be used (http basic auth)"
param "github_token", "the OAuth token to be used "

mark_as_read_only

display_type :table
add_columns [ :name, :description, :ssh_url ] 

execute do |params|
  result = []
  
  if params.has_key?('github_user') and params.has_key?('github_password')
    result = JSON.parse(@op.http_get("url" => "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com/user/repos"))
  elsif params.has_key?('github_token')
    result = JSON.parse(@op.http_get("url" => "https://api.github.com/user/repos?access_token=#{params["github_token"]}"))
  else
    raise "need either github user/password or access token to authenticate against github"
  end
  
  result.each do |x|
    x["full_name"] = x["owner"]["login"] + '/' + x["name"]
  end
  
  result
end