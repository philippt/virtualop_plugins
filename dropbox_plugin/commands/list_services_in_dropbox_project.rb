description "returns vop services contained in a dropbox project"

param :dropbox_token
param :dropbox_project

#mark_as_read_only

add_columns [ :name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

execute do |params|
  result = []

  services_to_load = {}
  
  
  dotvop_dir = "/projects/#{params["project"]}/.vop"
  dotvop_content = @op.list_dropbox_folders("path" => dotvop_dir)
  
  with_dropbox(params) do |client|
    
    # TODO load plugin
    plugin_files = dotvop_content.select { |x| /\.plugin$/.match(x["name"]) }
    raise "more than one plugin file found in #{dotvop_dir}" if plugin_files.size > 1
    plugin_file = plugin_files.first
    plugin_name = plugin_file["name"].split(".").first
    source, metadata = client.get_file_and_metadata(plugin_file["path"])      
    
    loader = PluginLoader.new(@op)
    the_plugin = loader.new_plugin(PluginBase.new(@op, nil, plugin_name))
        
    loader.instance_eval(source)
    $logger.info "loaded plugin #{plugin_name}"
    
    #[ "helper", "command" ].each do |thing|
    [ "command" ].each do |thing|
      thing_path = "#{dotvop_dir}/#{thing}s"
      if @op.dropbox_file_exists("path" => thing_path)
        @op.list_dropbox_folders("path" => thing_path).each do |thing_file|
          matched = /(.+)\.rb$/.match(thing_file["name"]) or next
          name = matched.captures.first
          source, metadata = client.get_file_and_metadata(thing_file["path"])
          load_method = "load_#{thing}"
          the_plugin.send(load_method.to_sym, name, source)
        end
      end
    end 
    
    services_path = "#{dotvop_dir}/services"
    if @op.dropbox_file_exists("path" => services_path)
      @op.list_dropbox_folders("path" => services_path).each do |service_file|
        matched = /(.+)\.rb$/.match(service_file["name"]) or next
        name = matched.captures.first
        source, metadata = client.get_file_and_metadata(service_file["path"])
        
        service = ServiceDescriptorLoader.read(@op, name, source).services.first
        service["full_name"] = [ params["project"], name ].join("/")
        result << service.clone()
      end
    end
  end
  
  if result.size > 0
    project_name = params["project"]
    
    same_name = result.select { |x| x["name"] == project_name }
    if same_name.size > 0
      default_service = result.delete same_name.first
      #puts "moving default service #{default_service["name"]} to the front of the list"     
      result.unshift default_service
    else
      $logger.warn "did not find default service - looked for '#{default_service_name}'"
    end
  end  
  
  result
  
  result
end


