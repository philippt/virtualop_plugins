description "reads file content from dropbox"

param :dropbox_token
param! "path", "path relative to Apps/vop"

# TODO this could be read-only, no?

execute do |params|
  $logger.info "reading file from dropbox: #{params["path"]}"
  with_dropbox(params) do |client|
    client.get_file(params["path"])
  end
end