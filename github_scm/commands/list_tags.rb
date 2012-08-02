description "returns the tags that have been set on a github project"

github_params
param! :github_project

#mark_as_read_only

#add_columns [ :tag, :sha ]

execute do |params|
  result = JSON.parse(@op.http_get("url" => "https://api.github.com/repos/#{params["github_project"]}/git/tags/047e0e70d461a4f25cb259e48bd280e5bea07dee?access_token=#{params["github_token"]}")).map do |ref|
    ref
    #{
    #  "sha" => ref["object"]["sha"],
    #  "name" => ref["ref"].split("/").last
    #}
  end
  pp result
  result
end
