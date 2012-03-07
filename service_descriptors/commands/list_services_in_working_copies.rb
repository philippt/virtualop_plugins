description "goes through all working copies and looks for service descriptors"

param :machine

mark_as_read_only

add_columns [ :name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
  
  machine.list_working_copies.each do |working_copy|
    dir = working_copy["path"]
  
    machine.with_files(
      "directory" => dir, 
      "pattern" => params.has_key?('pattern') ? params['pattern'] : '.vop/services/*',
      "what" => lambda do |file|
        
        full_name = "#{dir}/#{file}"
        source = machine.read_file("file_name" => full_name)
        
        $logger.debug "found #{file} : ***\n#{source}\n***\n"
        name = file.split("/").last.split(".").first
        service = ServiceDescriptorLoader.read(name, source).services.first
        
        service["file_name"] = full_name
        service["dir_name"] = dir + "/" + name
        
        result << service
      end
    )
  end
  result
end
