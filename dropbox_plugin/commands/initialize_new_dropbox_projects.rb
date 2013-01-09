description "checks periodically for new dropbox projects and writes metadata into them"

param :dropbox_token

execute do |params|
  projects = []
  @op.without_cache do
    projects = @op.list_dropbox_projects
  end
  projects.each do |project|
    next if project["has_metadata"]
    puts "initializing #{project["name"]}"
    @op.initialize_dropbox_project("project" => project["name"])
    
    @op.without_cache do
      @op.troll_dropbox_folders("path" => project["path"])
    end
  end
end
