description "adds a new public SSH key to a github account, thereby opening access for the corresponding private key"

github_params

param! "title", "textual description of the key"
param! "key", "the public key data"

execute do |params|
  result = []
  
  if params.has_key?('github_user') and params.has_key?('github_password')
    data = {
      "title" => params["title"],
      "key" => params["key"]
    }
    tempfile = @op.write_tempfile("data" => data.to_json())
  
    @op.with_machine("localhost") do |localhost|
      http_result = localhost.http_post(
        "data_file" => tempfile.path, 
        "target_url" => "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com/user/keys"
      )
      result = JSON.parse(http_result)
    end
  elsif params.has_key?('github_token')
    result = JSON.parse(@op.http_get("url" => "https://api.github.com/user/repos?access_token=#{params["github_token"]}"))
  else
    raise "need either github user/password or access token to authenticate against github"
  end
  result
end
