param :machine
param :working_copy

add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

on_machine do |machine, params|
  details = @op.working_copy_details(params)
  #pp details
  machine.list_services_in_directory("directory" => details["path"])
end
