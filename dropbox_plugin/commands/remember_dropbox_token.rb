description "stores a dropbox authorization token in the context"

param! "access_token_key", "an access token that allows access to dropbox"
param! "access_token_secret", "the secret for the token provided"

execute_request do |request, response|
  response.set_context('dropbox_token' => [ request.get_param_value('access_token_key'), request.get_param_value('access_token_secret')])
end