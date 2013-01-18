param :machine, "the host onto which to deploy"
param :stack
param "prefix", "prefix for the VM names"

accept_extra_params

add_columns [ :name, :status ]

on_machine do |machine, params|
  result = []
  
  @op.resolve_stack(params).each do |m|
    command_name = nil
    
    options = {}
    
    #vm_name = (params["prefix"] || '') + machine_def.name
    #full_name = vm_name + '.' + machine.name
    vm_name = m["name"]
    full_name = m["full_name"]
    
    option_string = ''
    machine_def.data.each do |k,v|
      option_string += " #{k}=#{v}"
    end
    @op.create_jenkins_job("job_name" => full_name, "command_string" => "kaboom machine=#{full_name} #{option_string}")
    result << {
      "name" => vm_name,
      "status" => "ok"
    }
  end
  result
end