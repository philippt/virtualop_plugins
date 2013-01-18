param :machine, "a host to work with"
param :stack

accept_extra_params

on_machine do |machine, params|
  host_name = params["machine"]
  
  params["stack"].each do |stack_name|
    p = params.clone
    p["stack"] = stack_name
    @op.generate_jenkins_jobs_for_stack(p).each do |job|
      @op.trigger_build("jenkins_job" => job["full_name"])
    end
    
    command_name = stack_name + "_stackinstall"
    p.delete("stack")
    p.merge! params["extra_params"]
    @op.send(command_name.to_sym, p)
  end
  
end
