description "returns the params mandatory for installing the specified service"

param :machine
param! "working_copy", "fully qualified path to the working copy from which to install"
param! "service", "the name of the service contained inside the working copy that should be installed."
#param :working_copy
#param :service

add_columns [ :name , :description ]

on_machine do |machine, params|
  result = []
  
  service = machine.list_services_in_directory("directory" => params["working_copy"]).select { |x| x["name"] == params["service"] }.first
  p service
  service["install_command_params"].each do |param|
    result << {
      "name" => param.name,
      "description" => param.description
    }
  end
  result
end  
