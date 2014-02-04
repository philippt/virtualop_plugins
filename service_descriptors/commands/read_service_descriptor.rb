description "reads a service descriptor and returns a hash with the data"

param :machine
param! "file_name", "path to the service descriptor file"

display_type :hash

mark_as_read_only

on_machine do |machine, params|
  full_name = params["file_name"]
  source = machine.read_file("file_name" => full_name)
      
  name = full_name.split("/").last.split(".").first
  service = ServiceDescriptorLoader.read(@op, nil, name, source).services.first
  
  parts = full_name.split("/")
  2.times do 
    parts.pop 
  end
  service["dir_name"] = parts.join("/") 
  
  # TODO move to nagios_config_generator or wherever it's needed
  # if service.has_key?("dir_name")
    # command_dir = service["dir_name"] + '/' + 'nagios_commands'
    # if machine.file_exists("file_name" => command_dir)
      # h = {}
      # machine.list_files("directory" => command_dir).each do |file|
        # file_name = command_dir + '/' + file
        # h[file] = machine.read_file("file_name" => file_name)
      # end
      # service["nagios_commands"] = h
    # end
  # end
  
  service["file_name"] = full_name
  
  service
end
