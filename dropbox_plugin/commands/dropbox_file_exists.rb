description "checks if a file exists inside the dropbox"

param :dropbox_token
param! "path", "path relative to Apps/vop"

mark_as_read_only

execute do |params|
  result = false
  begin    
    @op.list_dropbox_folders(params)
    result = true
  rescue
  end
  result  
end    
