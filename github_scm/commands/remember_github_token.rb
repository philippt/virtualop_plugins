description "stores a github token in the context so that no authentication is needed in further calls"

param! "github_token", "the github token to store"

execute_request do |request, response|
  response.set_context('github_token' => request.get_param_value('github_token'))
end
