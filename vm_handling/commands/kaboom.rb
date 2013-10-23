description "terminates a machine and re-installs it"

param! :machine, 'the machine to kaboom', 
  :allows_extra_values => true,
  :default_param => true

param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 25
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

param "ip", "the static IP address for the new machine"

param :github_project
param :git_branch
param :git_tag

param "script_url", "http URL to a script that should be executed at the end of the installation"
param "location", "installation source for guest virtual machine kernel+initrd pair."

param "canned_service", "name of a canned service to install on the machine", :allows_multiple_values => true

param "http_proxy", "if specified, the http proxy is used for the installation and configured on the new machine"

accept_extra_params

execute do |params|
  parts = params['machine'].split('.')
  vm_name = parts.shift
  host_name = parts.join('.')

  p = params.clone
  p.delete("machine")
  p["vm_name"] = vm_name
  
  candidates = @op.list_machines.select { |x| x["full_name"] == params["machine"]}
  machine_exists = candidates.size > 0
  
  if machine_exists
    if @op.reachable_through_ssh("machine" => params["machine"])
      begin
        @op.with_machine(params["machine"]) do |machine|
          e = machine.environment
          p["environment"] = e if e && e != ''
        end      
      rescue => detail
        $logger.warn("could not retrieve params for kaboom from machine : #{detail.message}")
      end
    end
  end
  
  @op.with_machine(host_name) do |host|    
    host.terminate_vm("name" => vm_name) if host.list_vms.map { |x| x["name"] }.include? vm_name
    
    @op.flush_cache()
    
    #host.setup_vm(p)
    host.new_machine(p)
  end
end   

