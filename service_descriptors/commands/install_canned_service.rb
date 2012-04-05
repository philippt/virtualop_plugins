description "installs a service from a 'canned' service descriptor, i.e. a descriptor available to the virtualop, but not from the target machine"

param :machine
#param! :descriptor_machine 
param! :canned_service
param "extra_params", "a hash of extra parameters for the service install command"

accept_extra_params

on_machine do |machine, params|  
  service_row = @op.list_available_services("machine" => "localhost").select do |x|
    x["full_name"] == params["service"]
  end.first
  
  service_name = params["service"]
  #descriptor_dir = service_row["dir_name"]
  
  params["descriptor"] = service_row["file_name"]  
  
  $logger.info("installing canned service #{params["service"]} onto #{params["machine"]}")
  
  params.delete("service")
  
  @op.install_service_from_descriptor(params)  
end
