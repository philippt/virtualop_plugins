description 'returns a list of actions that should be displayed for a machine'

param :machine

#mark_as_read_only

add_columns [ :name, :title ]

on_machine do |machine, params|
  result = []
  
  begin
    service_names = machine.list_unix_services.map { |row| row["name"] }
  
    if service_names.include?("libvirtd")
      result << {
        "name" => "vm_click",
        "title" => "new vm"
      } 
    end
  rescue
    $logger.warn "couldn't load service-specific actions - something wrong with list_unix_services?"
  end
  
  result << {
    "name" => "git_clone",
    "title" => "add working copy"
  }
  
  result << {
    "name" => "install_service_from_github",
    "title" => "install github project"
  }
  
  if service_names.include?("httpd")
    result << {
      "name" => "add_static_vhost",
      "title" => "add static vhost"
    }
    
    result << {
      "name" => "configure_reverse_proxy",
      "title" => "configure reverse proxy"
    }
  end
  
  result << {
    "name" => "restart_unix_service",
    "title" => "restart unix service"
  }    
  
  result << {
    "name" => "install_canned_service",
    "title" => "install service"
  }
  
  result
end



