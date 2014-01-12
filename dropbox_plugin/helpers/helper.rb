def with_dropbox(params, &block)
  dbsession = DropboxSession.new(ENV['DROPBOX_ID'], ENV['DROPBOX_SECRET'])
  dbsession.set_access_token(params['dropbox_token'].first, params['dropbox_token'].last)
  client = DropboxClient.new(dbsession, :app_folder) #raise an exception if session not authorized
  block.call(client)   
end