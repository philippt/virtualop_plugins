contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.is_a?(Hash) && service.has_key?('unix_service')
    unix_service_name = machine.unix_service_name("unix_service" => service["unix_service"])
    machine.mark_unix_service_for_autostart('name' => unix_service_name)
  elsif service.is_a?(String)
    machine.mark_unix_service_for_autostart('name' => service)
  end
end