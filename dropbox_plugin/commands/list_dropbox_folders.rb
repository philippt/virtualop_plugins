description "returns the content of a dropbox folder"

# TODO this way, we include the access token into the cache key. do we want that?
param! "access_token_key", "an access token that allows access to dropbox"
param! "access_token_secret", "the secret for the token provided"
param "path", "path to the dropbox folder whose contents should be listed", :default_value => '/'

mark_as_read_only

add_columns [ :path, :icon, :modified, :size ]

ACCESS_TYPE = :app_folder
execute do |params|
  dbsession = DropboxSession.new(ENV['DROPBOX_ID'], ENV['DROPBOX_SECRET'])
  dbsession.set_access_token(params['access_token_key'], params['access_token_secret'])
  client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
  #@info = client.account_info # look up account information
  client.metadata(params['path'])["contents"]
end
