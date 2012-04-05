description "goes through all working copies that contain services and loads service plugins"

param :machine

on_machine do |machine, params|
  result = []
  machine.list_services_in_working_copies.each do |service|
    if service.has_key?("plugin_file_name") and service["plugin_file_name"] != nil 
      machine.load_plugin('plugin_file_name' => service["plugin_file_name"])
      result << service["full_name"]
    else
      $logger.warn("not loading plugin because there's no plugin_file_name for service '#{service["full_name"]}' : #{service.to_json}")
    end
  end
  result
end
