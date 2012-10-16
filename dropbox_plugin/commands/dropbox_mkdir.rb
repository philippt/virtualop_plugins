description "creates a directory inside the dropbox"

param :dropbox_token
param! "path", "path relative to Apps/vop"

execute do |params|
  with_dropbox(params) do |client|
    dir = params["path"]
    client.file_create_folder(dir) unless @op.dropbox_file_exists("path" => dir)
    @op.without_cache do
      @op.list_dropbox_folders("path" => dir)
    end
  end
end  