description "installs or kabooms the machines defined in a stack onto a virtualization host"

param :machine, "the host onto which to deploy"
param :stack
param "prefix", "prefix for the VM names"

accept_extra_params

add_columns [ :name, :status ]

on_machine do |machine, params|
  result = []
  p = params.clone
  p.delete("machine")
  
  
  @op.resolve_stack(p).each do |machine_def|
    command_name = nil
    
    #options = params["extra_params"].clone()
    options = {}
    
    vm_name = (params["prefix"] || '') + machine_def.name
    full_name = vm_name + '.' + machine.name
    
    if machine.list_vms.select { |x| x["name"] == vm_name }.size > 0
      command_name = "kaboom"
      options["machine"] = full_name
    else
      command_name = "setup_vm"
      options["machine"] = machine.name
      options["vm_name"] = vm_name
    end
    options.merge! machine_def.data
    $logger.info "#{command_name} #{options.to_json()}"
    
    status = nil
    begin
      @op.send(command_name.to_sym, options)
      #raise "foo" if vm_name == "ci_powerdns"
      status = "ok"
    rescue => detail
      $logger.warn("could not rollout to #{full_name} : #{detail.message}\n#{detail.backtrace.join("\n")}")
      status = "error"
    end    
    result << {
      "name" => full_name,
      "status" => status
    }
  end
  result
end
