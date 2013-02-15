param :dropbox_token
param! "name", "a name for the new project"

execute do |params|
  @op.dropbox_mkdir("path" => "/projects/#{params["name"]}")
  @op.without_cache do
    @op.list_dropbox_projects
  end
  @op.initialize_dropbox_project("project" => params["name"])
end


