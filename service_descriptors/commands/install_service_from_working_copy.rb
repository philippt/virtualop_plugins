description "installs a service that is available as working copy on a target_machine"

param :machine
param :working_copy
param! "service", "the name of the service contained inside the working copy that should be installed."

accept_extra_params

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  vop_dir = "#{path}/.vop"
  if machine.file_exists("file_name" => vop_dir)
    params.merge!({
      "descriptor" => vop_dir + "/services/#{params["service"]}.rb", 
      "descriptor_machine" => machine.name,
      "service_root" => path
    })
    
    
    if params.has_key?('extra_params')
      puts "got extra params:"
      pp params['extra_params']
      params["extra_params"].each do |k,v|
        params[k] = v
      end
    end
    
    machine.install_service_from_descriptor(params)
  end  
end
