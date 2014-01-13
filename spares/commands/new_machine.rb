description "installs a new machine, using a spare VM if possible"

param :machine

param! "vm_name", "the name for the VM to be created"

param "memory_size", "the amount of memory (in MB) that should be allocated for the new VM", :default_value => 512
param "disk_size", "disk size in GB for the new VM", :default_value => 25
param "vcpu_count", "the number of virtual CPUs to allocate", :default_value => 1

#param "ip", "the static IP address for the new machine"

param :github_project
param :git_branch
param :git_tag

param "canned_service", "name of a canned service to install on the machine", :allows_multiple_values => true

param :environment

accept_extra_params

notifications

on_machine do |machine, params|
  full_name = spare = nil
  
  @op.with_lock("name" => "new_machine", "extra_params" => { "machine" => params["machine"] }) do
    spares = machine.list_spares
    if spares.size > 0    
      spare = spares.first
      p = { "machine" => spare["full_name"], "new_name" => params["vm_name"] }
      p.merge_from params, :memory_size
      full_name = @op.convert_spare(p)
    end    
  end
  
  if spare
    @op.with_machine(full_name) do |vm|
      vm.write_environment("environment" => params["environment"]) if params.has_key?("environment")
            
      # TODO copied from setup_vm, extract into deploy
      if params.has_key?('canned_service')
        params['canned_service'].each do |canned_service|
          p = {
            "service" => canned_service
          }
          if params.has_key?("extra_params")
            p["extra_params"] = params["extra_params"]
          end
          vm.install_canned_service(p)
        end
      end
      
      if params.has_key?('github_project')
        vm.install_service_from_github(params) 
      end  
      
      if params.has_key?('script_url')
        vm.execute_remote_command("url" => params['script_url'])
      end
      
      vm.change_runlevel("runlevel" => "running")
      
      vm.rm_if_exists("file_name" => "/etc/profile.d/http_proxy.sh")
      
      vm.hash_to_file("file_name" => "/var/lib/virtualop/new_machine_params", "content" => params)
      vm.write_file("target_filename" => "/var/lib/virtualop/installation_packages", "content" => vm.list_packages.to_yaml)
      vm.name
    end
  else
    @op.setup_vm(params)  
  end
end  
