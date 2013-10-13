description "installs a service from a 'canned' service descriptor, i.e. a descriptor available to the virtualop, but not from the target machine"

param :machine
param! :canned_service

accept_extra_params

on_machine do |machine, params|
  service_rows = @op.list_available_services("machine" => "localhost").select do |x|
    x["full_name"] == params["service"]
  end
  raise "no such service : #{params["service"]}" unless service_rows.size > 0
  service_row = service_rows.first
  
  service_name = params["service"]
  
  params["descriptor"] = service_row["file_name"]  
  
  if machine.list_installed_services.include? params["service"]
    @op.comment("service #{service_name} already installed, nothing to do.")
  else
    $logger.info("installing canned service #{params["service"]} onto #{params["machine"]}")
    
    params.delete("service")
    
    if params.has_key?('extra_params') && params['extra_params']
      params["extra_params"].each do |k,v|
        params[k] = v
      end
    end
    
    @op.install_service_from_descriptor(params)  
  end
end
