description "returns the branches of a github project"

github_params
param! :github_project

mark_as_read_only

add_columns [ :name, :sha ]

execute do |params|
  result = JSON.parse(@op.http_get("url" => "https://api.github.com/repos/#{params["github_project"]}/git/refs/heads?access_token=#{params["github_token"]}")).map do |ref|
    $logger.info ref.pretty_inspect
    {
      "sha" => ref["object"]["sha"],
      "name" => ref["ref"].split("/").last
    }
  end
  result
end
