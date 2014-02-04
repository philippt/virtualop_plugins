description "installs a new machine, using a spare VM if possible"

param! "vm_name", "the name for the VM to be created"

param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 25
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

#param "ip", "the static IP address for the new machine"

param :github_project
param :git_branch
#param :git_tag

#param "canned_service", "name of a canned service to install on the machine", :allows_multiple_values => true

param "environment", "if specified, the environment is written into a config file so that it's available through $VOP_ENV", :lookup_method => lambda {
  @op.list_environments
}

accept_extra_params

execute do |params|
  @op.new_machine(params.merge({
    "machine" => @op.installation_target
  }))  
end
