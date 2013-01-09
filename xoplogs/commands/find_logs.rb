description "returns logfiles on a machine"

param :machine

add_columns [ :service, :path, :source, :format ]

on_machine do |machine, params|
  result = []
  machine.list_services.each do |service|
    if service.has_key? "domain"
      #$logger.info "looking for >>#{service["domain"]}<<"
      # TODO there appears to be something rotten here
      vhosts = machine.list_configured_vhosts.select { |vhost| vhost["domain"].strip.chomp == service["domain"].first.first.strip.chomp }
      #$logger.info "found #{vhosts.size} vhosts for service #{service["name"]} through domain >>#{service["domain"]}<<"
      #pp vhosts
      if vhosts.size > 0
        vhosts.each do |vhost|
          if vhost.has_key?("log_path") and machine.file_exists("file_name" => vhost["log_path"])
            result << {
              "service" => service["name"],
              "path" => vhost["log_path"],
              "source" => "apache",
              "format" => vhost["log_format"]
            }
          end  
        end
      else
        #$logger.info "configured vhosts : #{machine.list_configured_vhosts.map { |x| ">>#{x["domain"]}<<" }.join("\n")}"
      end
    end
    
    if service.has_key? "log_file"
      log_file = service["log_file"]
      log_file = service["service_root"] + '/' + log_file unless /^\//.match(log_file)      
      if machine.file_exists("file_name" => log_file) 
        result << {
          "service" => service["name"],
          "path" => log_file,
          "source" => service["name"],
          "format" => "freestyle"          
        }
      end
    end
  end  
  result
end
