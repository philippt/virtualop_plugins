description "installs a service that is available as working copy on a target_machine"

param :machine
param! "working_copy", "fully qualified path to the working copy from which to install"
param! "service", "the name of the service contained inside the working copy that should be installed."
param "extra_params", "a hash of extra parameters for the service install command"

accept_extra_params

on_machine do |machine, params|
  vop_dir = params["working_copy"] + "/.vop"
  if machine.file_exists("file_name" => vop_dir)
    #machine.install_service_from_descriptor("descriptor_machine" => machine.name, "descriptor_dir" => vop_dir, "extra_params" => params["extra_params"])

    params.merge!({
      "descriptor" => vop_dir + "/services/#{params["service"]}.rb", 
      "descriptor_machine" => machine.name 
    })
    machine.install_service_from_descriptor(params)
  end  
end
