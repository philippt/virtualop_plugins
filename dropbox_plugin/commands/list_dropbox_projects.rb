description "returns vop projects stored in the current user's dropbox"

param :dropbox_token

mark_as_read_only

add_columns [ :name, :modified, :has_metadata ]

execute do |params|
  @op.list_dropbox_folders("path" => "/projects").each do |x|
    x["has_metadata"] = @op.dropbox_file_exists("path" => "#{x["path"]}/.vop")
    x
  end
end
