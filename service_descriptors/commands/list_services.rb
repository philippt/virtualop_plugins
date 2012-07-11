description "returns services that are configured to run on this machine"

param :machine

add_columns [ :name, :service_root, :runlevel, :unix_service, :is_startable ]

mark_as_read_only

on_machine do |machine, params|
  machine.list_installed_services.map do |service_name|
    machine.service_details("service" => service_name)
  end
end  
