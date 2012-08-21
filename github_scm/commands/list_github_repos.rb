description 'lists the github repositories for a user'

github_params

mark_as_read_only

display_type :table
add_columns [ :full_name, :ssh_url, :private ] 

execute do |params|
  result = []
  
  if params.has_key?('github_user') and params.has_key?('github_password')
    result = JSON.parse(@op.http_get("url" => "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com/user/repos"))
  elsif params.has_key?('github_token') and params["github_token"]
    result = JSON.parse(@op.http_get("url" => "https://api.github.com/user/repos?access_token=#{params["github_token"]}"))
  else
    raise "need either github user/password or access token to authenticate against github"
  end
  
  result.each do |x|
    x["full_name"] = x["owner"]["login"] + '/' + x["name"]
  end
  
  result
end