description "reads a service descriptor and returns a hash with the data"

param :machine
param! "file_name", "path to the service descriptor file"

display_type :hash

#mark_as_read_only

on_machine do |machine, params|
  full_name = params["file_name"]
  source = machine.read_file("file_name" => full_name)
      
  name = full_name.split("/").last.split(".").first
  service = ServiceDescriptorLoader.read(@op, nil, name, source).services.first
  
  service["file_name"] = full_name
  
  service
end