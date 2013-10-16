#add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

display_type :list

execute do |params|
  service_plugins = @op.list_all_plugins("tag_filter" => "canned_services").select { |x| x["active"] }.map { |x| x["name"] }

  result = []  
  @op.with_machine('localhost') do |localhost|
    config_string("descriptor_dirs").each do |dir|
      localhost.find("path" => dir, "path_filter" => "*/services/*.rb").each do |file|
        /([^\/]+)\/services\/(.+)\.rb$/ =~ file or next
        next unless service_plugins.include? $1
        result << "#{$1}/#{$2}"        
      end
    end
    
  end
  
  result.sort
  
  # result = []
  # @op.with_machine('localhost') do |localhost|
    # plugin_names.each do |plugin_name|
      # plugin = @op.plugin_by_name(plugin_name)
      # puts plugin.path
#       
      # #localhost.find("type" => "f", "path" => plugin.services_dir, 
      # #  "path_filter" => "*/services/*").each do |file|
      # #end
#       
      # localhost.list_files(plugin.services_dir).each do |file|
        # /(.+)\.rb$/ =~ file or next 
        # short_name = $1
        # result << "#{plugin_name}/#{short_name}"
      # end
      # #plugin.load_remote_services(localhost, plugin.path)
#       
    # end
  # end
#   
  # result
end
