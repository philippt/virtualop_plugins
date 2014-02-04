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
    
    options = {}
    
    vm_name = (params["prefix"] || '') + machine_def.name
    full_name = vm_name + '.' + machine.name
    
    command_name = "kaboom"
    options["machine"] = full_name
    
    options.merge! machine_def.data
    $logger.info "#{command_name} #{options.to_json()}"
    
    status = nil
    begin
      @op.send(command_name.to_sym, options)
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
