description "creates a new project repository in github"

github_params
param! "name", "name for the new project"

execute do |params|
  data = {
    "name" => params["name"]
  }
  pp data
  tempfile = @op.write_tempfile("data" => data.to_json())

  result = nil
  @op.with_machine("localhost") do |localhost|
    http_result = localhost.http_post(
      "data_file" => tempfile.path, 
      "target_url" => github_url(params, '/user/repos')
    )
    result = JSON.parse(http_result)
    pp result
  end

  #result
  
  @op.without_cache do
    @op.list_github_repos
  end
end

