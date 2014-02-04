description "returns the virtualop services found in the specified github project"

github_params
param! :github_project
param :git_branch

# TODO careful with that - looks like we're missing a clone() here (or something else, actually)
mark_as_read_only

#add_columns [ :path, :type, :sha ]
add_columns [ :name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

# TODO refactor
# TODO deprecated - should be replaced by services_in_github_project
execute do |params|
  result = []
  
  files = @op.get_tree(params.merge({ "recursive" => 1 }))
  
  params.delete("github_project")
  params.delete("git_branch")
  
  plugin_name = nil
  the_plugin = nil
  services_to_load = {}
  descriptor = []
  
  dotvop = files.select { |x| /^\.vop\//.match x["path"] }.sort { |x,y| x["path"] <=> y["path"] }.reverse
  if dotvop.size > 0
    descriptor = dotvop.map do |row|
      # remove the '.vop/' part
      parts = row["path"].split("/")
      parts.shift
      row["file"] = parts.join("/")
      row
    end
  else
    # TODO handle the other directory layout (e.g. virtualop/service_descriptors) here ? 
    files.each do |file|
      if matched = /^(.+)\/(.+).plugin$/.match(file["path"])
        service_name, plugin_name = matched.captures
         
      end
    end
    
  end
  
  things_to_load = {
    "helper" => {},
    "command" => {}
  }
  
  descriptor.each do |row|
    file = row["file"]
    
    if matched = /(.+)\.plugin$/.match(file)
      plugin_name = matched.captures.first
      $logger.info "found plugin #{plugin_name}"
      
      p = params.clone
      p["blob_url"] = row["url"]    
      source = @op.get_blob(p).clone()
      
      loader = PluginLoader.new(@op)
      the_plugin = loader.new_plugin(PluginBase.new(@op, nil, plugin_name))
        
      loader.instance_eval(source)
      
      plugin_name
    elsif matched = /(helpers|commands)\/(.+)\.rb$/.match(file)
      p = params.clone
      p["blob_url"] = row["url"]    
      source = @op.get_blob(p).clone()
      
      thing = matched.captures.first[0..-2]
      name = matched.captures[1]
      things_to_load[thing][name] = source
    elsif matched = /services\/(.+)\.rb$/.match(file)
      service_name = matched.captures.first
      
      p = params.clone
      p["blob_url"] = row["url"]    
      source = @op.get_blob(p).clone()
      
      services_to_load[service_name] = source
    end
  end
  
  things_to_load.each do |thing,hash|
    load_method = "load_#{thing}"
    hash.each do |name, source|
      the_plugin.send(load_method.to_sym, name, source)
    end
  end
  
  services_to_load.each do |service_name, source|
    begin
      service = ServiceDescriptorLoader.read(@op, the_plugin, service_name, source).services.first
      service["full_name"] = [ plugin_name, service_name ].join("/")
      result << service.clone()   
    rescue => detail
      $logger.error("could not load service descriptor #{service_name} : #{detail.message}")
    end
  end
  
  #pp result
  if result.size > 0
    project_name = plugin_name
    
    default_service_name = project_name + '/' + project_name
    same_name = result.select { |x| x["full_name"] == (default_service_name) }
    if same_name.size > 0
      default_service = result.delete same_name.first
      puts "moving default service #{default_service["name"]} to the front of the list"     
      result.unshift default_service
    else
      puts "did not find default service - looked for '#{default_service_name}'"
    end
  end  
  
  result
end
 