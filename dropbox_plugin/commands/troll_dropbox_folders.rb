description "goes recursively through a dropbox folder and gets the complete metadata tree"

param :dropbox_token
param! "path", "path relative to Apps/vop"

mark_as_read_only

add_columns [ :name, :path, :icon, :modified, :size ]

execute do |params|
  result = []
  @op.list_dropbox_folders("path" => params["path"]).each do |entry|
    result << entry
    if entry["is_dir"]
      result += @op.troll_dropbox_folders("path" => entry["path"])  
    end
  end
  result
end
