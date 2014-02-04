description "returns the tags that have been set on a github project"

github_params
param! :github_project

mark_as_read_only

add_columns [ :name, :sha ]

execute do |params|
  JSON.parse(@op.http_get("url" => "https://api.github.com/repos/#{params["github_project"]}/tags?access_token=#{params["github_token"]}")).map do |ref|
    ref["sha"] = ref["commit"]["sha"] if ref.has_key?("commit") and ref["commit"].has_key?("sha")
    ref
  end
end
