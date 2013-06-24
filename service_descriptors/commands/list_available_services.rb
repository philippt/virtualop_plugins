description "returns a list of services that can be installed on machines"

param :machine, "the machine to read descriptors from", { :default_value => 'localhost', :mandatory => false }

mark_as_read_only

add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

# TODO cleanup (see list_services_in_github_project and filter plugins that are not configured/loaded
on_machine do |machine, params|
  result = []
    
  config_string("descriptor_dirs").each do |dir|
    
    machine.with_files(
      "directory" => dir, 
      "pattern" => "*/services/*",
      "what" => lambda do |file|
        full_name = "#{dir}/#{file}"
        
        $logger.info "reading service from #{full_name}..."
        
        begin
          service = machine.read_service_descriptor("file_name" => full_name)
          parts = full_name.split("/")
          2.times do 
            parts.pop 
          end
          service["dir_name"] = parts.join("/") 
          
          parts = service["file_name"].split("/")
          idx = parts.index("services")
          offset = 1
          possible_name = parts[idx - offset]
          if possible_name == '.vop'
            offset += 1
            possible_name = parts[idx - offset]
          end
          
          service["full_name"] = possible_name + '/' + service["name"]
          
          result << service
        rescue => detail
          $logger.error("could not load service from #{full_name} : #{detail.message}\n#{detail.backtrace}")          
        end
      end
    )   
  end
  
  result
end
