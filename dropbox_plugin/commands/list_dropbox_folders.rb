description "returns the content of a dropbox folder"

param :dropbox_token

param "path", "path to the dropbox folder whose contents should be listed", :default_value => '/'

mark_as_read_only

add_columns [ :name, :path, :icon, :modified, :size ]

execute do |params|
  result = []
  $logger.info "reading dropbox metadata for #{params['path']}"
  with_dropbox(params) do |client|
    result = client.metadata(params['path'])["contents"]
  end
  
  result.map! do |x|
    x["name"] = x["path"].split("/").last
    x
  end
  
  result
end
