description "installs a service from a 'canned' service descriptor, i.e. a descriptor available to the virtualop, but not from the target machine"

param :machine
param! :descriptor_machine 
param! :canned_service

on_machine do |machine, params|
  
  service_row = @op.list_available_services.select do |x|
    x["name"] == params["service"]
  end.first
  
  service_name = params["service"]
  descriptor_dir = service_row["dir_name"]
  
  params["descriptor_dir"] = descriptor_dir
  params.delete("service")
  
  @op.install_service_from_descriptor(params)  
end
