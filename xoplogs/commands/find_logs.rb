description "returns logfiles on a machine"

param :machine

add_columns [ :service, :path, :source, :format, :parser ]

on_machine do |machine, params|
  result = []
  
  all_vhosts = []
  if machine.list_installed_services.include? "apache/apache"
    all_vhosts = machine.list_configured_vhosts
  end
  
  def check_file_exists(machine, log_file)
    prefixes = %w|/var/log|
    needs_root = false
    prefixes.each do |prefix|
      if /#{prefix}/ =~ log_file
        needs_root = true
        break
      end
    end
    
    file_exists = needs_root ?
      machine.as_user('root') { |root|
        root.file_exists("file_name" => log_file)
      } :
      machine.file_exists("file_name" => log_file)
      
    file_exists
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
          
          if vhost.has_key?("log_path") and check_file_exists(machine, vhost["log_path"])
            h = {
              "service" => service["full_name"],
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
        
        file_exists = nil
        
        if machine.machine_detail["os"] == 'windows'
          file_exists = machine.win_file_exists("file_name" => log_file)
        else
          # prefix relative paths
          unless /^[\/\$]/.match(log_file)
            if service.has_key?("service_root")
              log_file = service["service_root"] + '/' + log_file
            else
              log_file = machine.home + '/' + log_file 
            end
          end
          
          prefixes = %w|/var/log|
          needs_root = false
          prefixes.each do |prefix|
            if /#{prefix}/ =~ log_file
              needs_root = true
              break
            end
          end
          file_exists = needs_root ?
          machine.as_user('root') { |root|
            root.file_exists("file_name" => log_file)
          } :
          machine.file_exists("file_name" => log_file)
        end 
        
              
        if file_exists 
          h = {
            "service" => service["full_name"],
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
        "service" => "apache/apache",
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
