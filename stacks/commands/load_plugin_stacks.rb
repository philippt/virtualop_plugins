description "loads stacks for a plugin"

param! "plugin_name", "name of the plugin"
param :machine
param! "dir_name", "the .vop directory from which the plugin has been loaded"

contributes_to :post_plugin_load

execute do |params|
  plugin = @op.plugin_by_name(params["plugin_name"])
  $logger.info "loading stacks for #{plugin.name} from #{params["dir_name"]}"
  
  plugin_dir = params["dir_name"]
  
  result = []  
  @op.with_machine(params["machine"]) do |machine|
    the_dir = "#{plugin_dir}/stacks"
    
    if machine.file_exists("file_name" => the_dir)
      machine.with_files("directory" => the_dir, "pattern" => "*.rb", "what" => lambda { |file_name|
        stack_name = /([^\/]+)\.rb$/.match(file_name).captures.first
        source_path = "#{the_dir}/#{file_name}"
        stack_source = machine.read_file("file_name" => source_path)
        
        stack = StackLoader.read(@op, plugin, stack_name, stack_source, source_path).stacks.first
        $logger.info "loaded stack #{stack["name"]} from #{the_dir}@#{machine.name}"
        
        result << stack
      })
    end
  end
  
  @plugin.state[:stacks][plugin.name] = result
  
  result
end
