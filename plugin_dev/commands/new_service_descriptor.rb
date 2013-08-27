description "creates a new service descriptor skeleton in the first configured path for service descriptors"

param! "name"
param "path", "path to the directory in which the service descriptor should be created" 

execute do |params|  
  descriptor_path = params.has_key?('path') ? 
    params['path'] : 
    @op.plugin_by_name('service_descriptors').config_string('descriptor_dirs').first
    
  @op.new_plugin("name" => params["name"], "path" => descriptor_path, 
    "extra_folder" => [ "packages", "services" ]
  )
end
