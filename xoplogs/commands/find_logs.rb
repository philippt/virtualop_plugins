description "returns logfiles on a machine"

param :machine

add_columns [ :service, :path, :source, :format, :parser ]

on_machine do |machine, params|
  result = []
  
  all_vhosts = []
  if machine.list_installed_services.include? "apache"
    all_vhosts = machine.list_configured_vhosts
  end
  
  machine.list_services.each do |service|
    if service.has_key? "domain"
      #$logger.info "looking for >>#{service["domain"]}<<"
      # TODO there appears to be something rotten here
      domain = service["domain"]
      if domain.class.to_s == "Array"
        domain = domain.first
      end
      domain.strip! and domain.chomp!
      vhosts = all_vhosts.select { |vhost| vhost["domain"].strip.chomp == domain }
      #vhosts = all_vhosts.select { |vhost| vhost["domain"].strip.chomp == service["domain"].first.first.strip.chomp }
      if vhosts.size > 0
        vhosts.each do |vhost|
          all_vhosts.delete(vhost)
          
          if vhost.has_key?("log_path") and machine.file_exists("file_name" => vhost["log_path"])
            h = {
              "service" => service["name"],
              "path" => vhost["log_path"],
              "source" => "apache",
              "format" => vhost["log_format"]
            }
            result << h
          end  
        end
      else
        #$logger.info "configured vhosts : #{machine.list_configured_vhosts.map { |x| ">>#{x["domain"]}<<" }.join("\n")}"
      end
    end
    
    if service.has_key? "log_files"
      service["log_files"].each do |log|
        log_file = log["path"]
        log_file = service["service_root"] + '/' + log_file unless /^\//.match(log_file)      
        if machine.file_exists("file_name" => log_file) 
          h = {
            "service" => service["name"],
            "path" => log_file,
            "source" => service["name"],
            "format" => log["format"] || "freestyle",
          }
          h["parser"] = log["parser"] if log.has_key? "parser"          
          result << h 
        end
      end
    end
  end  
  
  all_vhosts.each do |vhost|
    if vhost.has_key? "log_path"
      result << {
        "service" => "apache",
        "path" => vhost["log_path"],
        "source" => "apache",
        "format" => vhost["log_format"]
      }
    end
  end
  
  result.each do |entry|
    entry["parser"] = "xop_apache" if entry["source"] == "apache" and entry["format"] == "vop"
  end
  
  result
end
