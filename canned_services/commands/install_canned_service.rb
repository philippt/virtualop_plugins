description "installs a service from a 'canned' service descriptor, i.e. a descriptor available to the virtualop, but not from the target machine"

param :machine
param! :canned_service
param "force", "set to true to install even if the service is installed already", :default_value => false

accept_extra_params

on_machine do |machine, params|
  service_name = params["service"]
  service_row = @op.canned_service_detail service_name

  should_install = true
    
  if machine.list_installed_services.include?(service_name) && params["force"].to_s != 'true'
    service = machine.service_details('service' => service_name)
    
    should_install = false
    
    if service.has_key?('release') && params.has_key?('extra_params') && params['extra_params'].has_key?('release') &&
       service['release'] != params['extra_params']['release']
      should_install = true
    end
    
  end
    
  if should_install
    @op.comment("installing canned service #{service_name} onto #{params["machine"]}")
    
    params.delete("service")
    params["descriptor"] = service_row["file_name"]  
    
    if params.has_key?('extra_params') && params['extra_params']
      params["extra_params"].each do |k,v|
        params[k] = v
      end
    end
    
    @op.install_service_from_descriptor(params)
  else
    @op.comment("service #{service_name} already installed, nothing to do.")
  end
end
