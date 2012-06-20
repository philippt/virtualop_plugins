description "looks for services defined in a working copy"

param :machine
param! "working_copy", "fully qualified path to the working copy"

mark_as_read_only
add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
  
  dir = params["working_copy"]
  dotvop_dir = dir + '/.vop'
  
  if machine.file_exists("file_name" => dotvop_dir)  
    plugin_files = machine.list_files("directory" => dotvop_dir).select { |x| /\.plugin$/.match(x) }.sort
    
    # TODO why is this loading plugins here?
    plugin_name = nil
    plugin_loaded_from = nil
    plugin_files.each do |plugin_file_name|
      plugin_name = machine.load_plugin('plugin_file_name' => dotvop_dir + '/' + plugin_file_name)
      plugin_loaded_from = plugin_file_name
    end
    
    $logger.info "loaded plugin '#{plugin_name}' from '#{plugin_loaded_from}'"
    
    machine.with_files(
      "directory" => dir, 
      "pattern" => '.vop/services/*',
      "what" => lambda do |file|
        service = machine.read_service_descriptor("file_name" => "#{dir}/#{file}")
        service["dir_name"] = dir 
        
        service["plugin_file_name"] = plugin_loaded_from unless plugin_loaded_from == nil
        service["plugin_name"] = plugin_name unless plugin_name == nil # TODO would this be a valid plugin?
        
        parts = service["file_name"].split("/")
        idx = parts.index("services")
        offset = 1
        possible_name = parts[idx - offset]
        if possible_name == '.vop'
          offset += 1
          possible_name = parts[idx - offset]
        end
        
        #service["full_name"] = possible_name + '/' + service["name"]
        service["full_name"] = plugin_name + '/' + service["name"]
        
        result << service
        
      end
    )
  end
  
  result
end



