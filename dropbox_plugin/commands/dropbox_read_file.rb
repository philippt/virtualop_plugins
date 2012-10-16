description "reads file content from dropbox"

param :dropbox_token
param! "path", "path relative to Apps/vop"

execute do |params|
  $logger.info "reading file from dropbox: #{params["path"]}"
  with_dropbox(params) do |client|
    client.get_file(params["path"])
  end
end