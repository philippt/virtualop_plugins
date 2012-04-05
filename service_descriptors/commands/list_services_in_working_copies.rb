description "goes through all working copies and looks for service descriptors"

param :machine

mark_as_read_only

#add_columns [ :name, :dir_name, :file_name ]
add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
  
  machine.list_working_copies.each do |working_copy|
    dir = working_copy["path"]
    
    machine.with_files(
      "directory" => dir, 
      "pattern" => '.vop/services/*',
      "what" => lambda do |file|
        plugin_file_name = dir + '/.vop/' + working_copy["project"].split("/").last + '.plugin'
        plugin_loaded_from = nil
        if machine.file_exists("file_name" => plugin_file_name)
          machine.load_plugin('plugin_file_name' => plugin_file_name)
          plugin_loaded_from = plugin_file_name          
        else
          $logger.info("no plugin file found in working copy, looked for #{plugin_file_name}")
        end
        service = machine.read_service_descriptor("file_name" => "#{dir}/#{file}")
        service["dir_name"] = dir 
        
        service["plugin_file_name"] = plugin_loaded_from unless plugin_loaded_from == nil
        
        parts = service["file_name"].split("/")
        idx = parts.index("services")
        offset = 1
        possible_name = parts[idx - offset]
        if possible_name == '.vop'
          offset += 1
          possible_name = parts[idx - offset]
        end
        
        #service["full_name"] = possible_name + '/' + service["name"]
        service["full_name"] = working_copy["project"].split("/").last + '/' + service["name"]
        
        result << service
        
      end
    )
  end
  
  result
end
