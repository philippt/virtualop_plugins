description "goes recursively through a dropbox folder and gets the complete metadata tree"

param :dropbox_token
param! "path", "path relative to Apps/vop"
param "blacklist", "directory names that should be ignored", :allows_multiple_values => true

mark_as_read_only

add_columns [ :name, :path, :icon, :modified, :size ]

execute do |params|
  result = []
  @op.list_dropbox_folders("path" => params["path"]).each do |entry|
    result << entry
    if entry["is_dir"]
      result += @op.troll_dropbox_folders("path" => entry["path"]) unless params.has_key?("blacklist") and params["blacklist"].include? entry["name"]  
    end
  end
  result
end
