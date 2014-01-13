description "returns repositories owned by an organisation"

github_params
param! "org", "the organisation for which repos should be returned", :lookup_method => lambda { @op.list_orgs.map { |x| x["login"] } }
param "with_service", "if set to true, we will try to find vop services in the github project (consumes time, energy and transatlantic bandwidth)", :default_value => false

add_columns [ :name, :description ]

mark_as_read_only

execute do |params|
  data = JSON.parse(@op.http_get("url" => github_url(params, "/orgs/#{params["org"]}/repos")))
  
  params['with_service'] ? @op.inspect_github_repos(params.merge('project_data' => data)) : data
end
