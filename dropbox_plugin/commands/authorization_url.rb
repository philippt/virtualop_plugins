description "returns a URL where the user can authorize the virtualop to access his dropbox"

execute do |params|
  session = DropboxSession.new(config_string('app_key'), config_string('app_secret'))
  session.get_request_token
  session.get_authorize_url
end
