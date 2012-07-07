description "adds a new public SSH key to a github account, thereby opening access for the corresponding private key"

github_params

param! "title", "textual description of the key"
param! "key", "the public key data"

execute do |params|
  result = []
  
  data = {
    "title" => params["title"],
    "key" => params["key"]
  }
  pp data
  tempfile = @op.write_tempfile("data" => data.to_json())

  @op.with_machine("localhost") do |localhost|
    http_result = localhost.http_post(
      "data_file" => tempfile.path, 
      "target_url" => github_url(params, '/user/keys')
    )
    result = JSON.parse(http_result)
    pp result
  end

  result
end
