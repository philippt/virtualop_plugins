description "goes through all working copies that contain services and loads service plugins"

param :machine

on_machine do |machine, params|
  result = []
  machine.list_services_in_working_copies.each do |service|
    if service.has_key?("plugin_file_name") and service["plugin_file_name"] != nil
      dotvop_dir = service["working_copy"] + '/.vop'
  
      if machine.file_exists("file_name" => dotvop_dir)  
        plugin_files = machine.list_files("directory" => dotvop_dir).select { |x| /\.plugin$/.match(x) }.sort
        
        plugin_name = nil
        plugin_loaded_from = nil
        plugin_files.each do |plugin_file_name|
          plugin_name = machine.load_plugin('plugin_file_name' => dotvop_dir + '/' + plugin_file_name)
          plugin_loaded_from = plugin_file_name
        end
      end
    
      $logger.info "loaded plugin '#{plugin_name}' from '#{plugin_loaded_from}'"
       
      #machine.load_plugin('plugin_file_name' => service["plugin_file_name"])
      result << service["full_name"]
    else
      $logger.warn("not loading plugin because there's no plugin_file_name for service '#{service["full_name"]}' : #{service.to_json}")
    end
  end
  result
end
