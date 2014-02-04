description "returns a list of services that can be installed"

param :machine

add_columns [ :full_name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

mark_as_read_only

on_machine do |machine, params|
  result = @op.list_available_services('machine' => 'localhost')
  result += machine.list_services_in_working_copies
      
  machine.list_installed_services.each do |service_name|
    result.delete_if { |x| x["name"] == service_name }
  end
  
  result
end
