description "initializes a vop project in the dropbox, i.e. writes the vop metadata structure into one of the subfolders of /projects"

param :dropbox_token
param :dropbox_project

execute do |params|
  with_dropbox(params) do |client|
    project_dir = "/projects/#{params["project"]}"
    dotvop_dir = project_dir + "/.vop"
    client.file_create_folder(dotvop_dir)
    
    %w|commands helpers templates|.each do |x|
      client.file_create_folder(dotvop_dir + '/' + x)      
    end
    #client.put_file("#{dotvop_dir}/helpers/helper.rb", "# helper for #{params["project"]}", true) # overwrite
    
    plugin_file_name = "#{dotvop_dir}/#{params["project"]}.plugin"
    plugin_file = read_local_template(:plugin_file, binding())
    client.put_file(plugin_file_name, plugin_file)
    
  end
  
  c = [ "# service #{params["project"]}",
          "static_html"
        ].join("\n")
  @op.add_service_to_dropbox_project("project" => params["project"], "name" => params["project"], "content" => c)
  
  @op.without_cache do
    @op.list_dropbox_projects
  end
end
