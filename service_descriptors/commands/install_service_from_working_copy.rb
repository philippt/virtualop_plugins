description "installs a service that is available as working copy on the target_machine"

param :machine
param! "working_copy", "fully qualified path to the working copy from which to install"

on_machine do |machine, params|
  vop_dir = params["working_copy"] + "/.vop"
  if machine.file_exists("file_name" => vop_dir)
    machine.install_service_from_descriptor("descriptor_machine" => machine.name, "descriptor_dir" => vop_dir)
  end  
end
