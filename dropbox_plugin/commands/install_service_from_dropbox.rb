description "installs a service from a dropbox project"

param :dropbox_token
param :dropbox_project

param :machine
#param! "target_dir", "the directory the service should be installed into"

accept_extra_params

#display_type :list

on_machine do |machine, params|
  service_root = "/var/www/#{params["project"]}"
  machine.sync_dropbox_folder("path" => "/projects/#{params["project"]}", "directory" => service_root, "force" => "true")
  
  machine.allow_access_for_apache("file_name" => service_root)
  
  p = {
    "descriptor_machine" => machine.name, 
    "descriptor" => "#{service_root}/.vop/services/#{params["project"]}.rb",
    "service_root" => service_root,
    "extra_params" => params["extra_params"]
  }
  # if params.has_key?('extra_params')
    # params["extra_params"].each do |k,v|
      # p[k] = v
    # end
  # end
  machine.install_service_from_descriptor(p)  
end
