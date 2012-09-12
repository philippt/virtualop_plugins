description "creates a new virtualop plugin skeleton"

param! "name", "the name for the new plugin"

execute do |params|
  @op.with_machine('localhost') do |localhost|
    plugin_dir = config_string('plugin_dir') + '/' + params["name"]
    localhost.mkdir("dir_name" => plugin_dir)
    %w|commands helpers templates|.each do |x|      
      localhost.mkdir("dir_name" => plugin_dir + '/' + x)
    end
    
    plugin_file_name = "#{plugin_dir}/#{params["name"]}.plugin"
    process_local_template(:plugin_file, localhost, plugin_file_name, binding())
  end
end