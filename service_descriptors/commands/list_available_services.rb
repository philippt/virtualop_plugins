description "returns a list of services that can be installed on machines"

param :machine, "the machine to read descriptors from", { :default_value => 'localhost', :mandatory => false }

mark_as_read_only

add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  result = []
    
  config_string("descriptor_dirs").each do |dir|
    result += machine.find_services_in_directory("directory" => dir)
  end
  
  result
end
