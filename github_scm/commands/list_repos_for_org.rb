description "returns repositories owned by an organisation"

github_params
param! "org", "the organisation for which repos should be returned", :lookup_method => lambda { @op.list_orgs.map { |x| x["login"] } }

add_columns [ :name, :description ]

execute do |params|
  JSON.parse(@op.http_get("url" => github_url(params, "/orgs/#{params["org"]}/repos")))
end
