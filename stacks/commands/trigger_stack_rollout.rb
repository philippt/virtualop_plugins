param :machine, "a host to work with"
param :stack

accept_extra_params

on_machine do |machine, params|
  host_name = params["machine"]
  
  params["stack"].each do |stack_name|
    p = params.clone
    p["stack"] = stack_name
    jenkins_jobs = @op.generate_jenkins_jobs_for_stack(p)
    
    command_name = stack_name + "_stackinstall"
    p.delete("stack")
    
    command = Thread.current['broker'].get_command(command_name)
    command.params.each do |cp|
      if (params["extra_params"] || {}).has_key?(cp.name)
        p[cp.name] = params["extra_params"][cp.name]
      end
    end
    
    #p.merge! params["extra_params"]
    @op.send(command_name.to_sym, p)
    
    sleep 30
    
    idx = 0
    jenkins_jobs.each do |job|
      @op.trigger_build("jenkins_job" => job["full_name"])
      if idx == 0
        how_many = 180
        @op.comment "sleeping #{how_many} seconds after launching first jenkins job"
        sleep how_many
      end
      idx += 1
    end
  end
  
end
