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
    
    option_string = ''
    machine_def.data.each do |k,v|
      option_string += " #{k}=#{v}"
    end
    @op.create_jenkins_job("job_name" => full_name, "command_string" => "kaboom machine=#{full_name} #{option_string}")
    result << {
      "name" => machine_def.name,
      "status" => "ok"
    }
  end
  result
end