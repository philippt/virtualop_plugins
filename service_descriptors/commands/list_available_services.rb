description "returns a list of services that can be installed on machines"

param :machine, "the machine to read descriptors from", { :default_value => 'localhost', :mandatory => false }

mark_as_read_only

add_columns [ :name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
    
  config_string("descriptor_dirs").each do |dir|
    machine.with_files(
      "directory" => dir, 
      "pattern" => "*/services/*",
      "what" => lambda do |file|
        
        full_name = "#{dir}/#{file}"
        source = machine.read_file("file_name" => full_name)
        
        $logger.debug "found #{file} : ***\n#{source}\n***\n"
        name = file.split("/").first
        service = ServiceDescriptorLoader.read(name, source).services.first
        
        service["file_name"] = full_name
        service["dir_name"] = dir + "/" + name
        
        result << service
      end
    )
  end
  
  result
end
