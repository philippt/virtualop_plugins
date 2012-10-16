description "checks periodically for new dropbox projects and writes metadata into them"

param :dropbox_token

execute do |params|
  while (true) do
    projects = []
    @op.without_cache do
      projects = @op.list_dropbox_projects
    end
    projects.each do |project|
      next if project["has_metadata"]
      puts "initializing #{project["name"]}"
      @op.initialize_dropbox_project("project" => project["name"])
      c = [ "# service #{project["name"]}",
            "static_html"
          ].join("\n")
      @op.add_service_to_dropbox_project("project" => project["name"], "name" => project["name"], "content" => c)
      @op.without_cache do
        @op.troll_dropbox_folders("path" => project["path"])
      end
    end
    sleep 15
  end
end
