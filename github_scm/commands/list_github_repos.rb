description 'lists the github repositories for a user'

github_params

param "with_service", "if set to true, we will try to find vop services in the github project (consumes time, energy and transatlantic bandwidth)", :default_value => false

mark_as_read_only

display_type :table
add_columns [ :full_name, :ssh_url, :private ]

ignore_extra_params 

execute do |params|
  result = []
  
  result = JSON.parse(@op.http_get("url" => github_url(params, '/user/repos'))).clone
  
  if params['with_service']
    result = @op.inspect_github_repos(params.merge({'project_data' => result}))    
  end
  
  result
end