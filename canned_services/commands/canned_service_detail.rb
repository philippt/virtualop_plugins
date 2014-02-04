param :canned_service, "", :default_param => true

display_type :hash

execute do |params|
  result = nil
  
  parts = params["service"].split('/')
  plugin_name = parts.first
  full_name = @op.plugin_by_name(plugin_name).path + '/services/' + parts.last + '.rb'
  
  @op.with_machine('localhost') do |localhost|
    $logger.info "reading service from #{full_name}..."
          
    begin
      service = localhost.read_service_descriptor("file_name" => full_name)
      parts = full_name.split("/")
      2.times do 
        parts.pop 
      end
      service["dir_name"] = parts.join("/") 
      
      #parts = service["file_name"].split("/")
      #idx = parts.index("services")
      #offset = 1
      #possible_name = parts[idx - offset]
      #if possible_name == '.vop'
      #  offset += 1
      #  possible_name = parts[idx - offset]
      #end
      
      #service["full_name"] = possible_name + '/' + service["name"]
      service["full_name"] = params['service']
      
      result = service
    rescue => detail
      $logger.error("could not load service from #{full_name} : #{detail.message}\n#{detail.backtrace}")          
    end
  end
  
  result
end