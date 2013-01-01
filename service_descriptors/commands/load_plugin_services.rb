description "loads services for a plugin"

param! "plugin_name", "name of the plugin"
param :machine
param! "dir_name", "the .vop directory from which the plugin has been loaded"

contributes_to :post_plugin_load

execute do |params|
  plugin = @op.plugin_by_name(params["plugin_name"])
  $logger.info "loading services for #{plugin.name} from #{params["dir_name"]}"
  
  plugin_dir = params["dir_name"]
  
  result = []  
  @op.with_machine(params["machine"]) do |machine|
    the_dir = "#{plugin_dir}/services"
    
    if machine.file_exists("file_name" => the_dir)
      machine.with_files("directory" => the_dir, "pattern" => "*.rb", "what" => lambda { |file_name|
        service_name = /([^\/]+)\.rb$/.match(file_name).captures.first
        service_source = machine.read_file("file_name" => "#{the_dir}/#{file_name}")
        
        service = ServiceDescriptorLoader.read(@op, plugin, service_name, service_source).services.first
        $logger.info "loaded service #{service["name"]} from #{the_dir}@#{machine.name}"
        result << service
      })
    end
  end
  result
end
