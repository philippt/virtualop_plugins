description "starts a background job that installs a new virtual machine from scratch"

param :machine
param "vm_name", "the name of the vm to setup", :mandatory => true
param "github_project", "the git project to install (e.g. philippt/virtualop)"
param "domain", "the domain at which the service should be available"
#param "script_url", "http URL to a script that should be executed at the end of the installation"

on_machine do |machine, params|
  command_string = "setup_vm disk_size=5 memory_size=512 vcpu_count=1 vm_name=#{params["vm_name"]} machine=#{params["machine"]}"
  if params.has_key?('github_project')
    command_string += " github_project=#{params["github_project"]}"
    if params.has_key?('domain')
      command_string += " domain=#{params["domain"]}"
    end
    #if params.has_key?('script_url')
    #  command_string += " script_url=#{params["script_url"]}"
    #end
  end
  
  build_number = @op.execute_as_jenkins_job(
    "command_string" => command_string
  )
  build_number
end


