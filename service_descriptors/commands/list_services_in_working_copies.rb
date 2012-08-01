description "goes through all working copies and looks for service descriptors"

param :machine

#mark_as_read_only

#add_columns [ :name, :dir_name, :file_name ]
add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
  
  machine.list_working_copies.each do |working_copy|
    result += machine.list_services_in_directory("directory" => working_copy["path"]).map do |service|
      service["working_copy"] = working_copy["path"]
      service
    end
  end
  
  result
end
