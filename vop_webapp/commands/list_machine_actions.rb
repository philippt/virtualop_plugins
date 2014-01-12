description 'returns a list of actions that should be displayed for a machine'

param :machine

mark_as_read_only

add_columns [ :name, :title ]

on_machine do |machine, params|
  result = []
  
  begin
    if machine.has_running_unix_service('service_name' => 'libvirtd')
      result << {
        #"name" => "vm_click",
        "name" => "setup_vm",
        "title" => "new vm"
      }
    end
    
    if machine.has_running_unix_service('service_name' => 'httpd')
    result << {
      "name" => "add_static_vhost",
      "title" => "add static vhost"
    }
    
    result << {
      "name" => "configure_reverse_proxy",
      "title" => "configure reverse proxy"
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
  
  result << {
    "name" => "restart_unix_service",
    "title" => "restart unix service"
  }    
  
  result << {
    "name" => "install_package",
    "title" => "install package"
  }
  
  if @op.list_plugins.include? "nagios_config_generator"
    result << {
      "name" => "generate_nagios_config",
      "title" => "generate nagios config"
    }
  end
  
  result << {
    "name" => "reload_metadata",
    "title" => "reload metadata"
  }
  
  result
end



