description "installs a service that is available as working copy on a target_machine"

param :machine
param :working_copy
param! "service", "the name of the service contained inside the working copy that should be installed."

accept_extra_params

on_machine do |machine, params|
  params["directory"] = machine.working_copy_details("working_copy" => params["working_copy"])["path"]
  params.delete("working_copy")
  
  machine.install_service_from_directory(params)
end
