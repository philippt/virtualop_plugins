description 'setup a new vm somewhere'

# TODO [core] wouldn't it be great to have something like params_as :setup_vm, :without => "machine" ?

param "vm_name", "the name for the VM to be created", :mandatory => true
param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 25
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

param "ip", "the static IP address for the new machine"

param :github_project
param :git_branch

#param "domain", "the domain at which the service should be available"
param "script_url", "http URL to a script that should be executed at the end of the installation"
param "location", "installation source for guest virtual machine kernel+initrd pair."

accept_extra_params

execute do |params|
  
  # Machine.new(
      # :name => params["vm_name"], 
      # :state => "installing",
      # :owner => Thread.current['request'].context.cookies['current_user_email']
    # ).save()
  
  raise "no installation target configured" unless config_string('installation_target')
  # TODO we could use a slightly more complicated algorithm here
  first_target = config_string('installation_target').first
  @op.setup_vm(params.merge({
    "machine" => first_target
  }))
end