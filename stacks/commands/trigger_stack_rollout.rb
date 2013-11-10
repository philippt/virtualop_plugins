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
    
    sleep 5
    
    idx = 0
    jenkins_jobs.each do |job|
      job["number"] = @op.trigger_build("jenkins_job" => job["full_name"])
      if idx == 0
        how_many = 30
        @op.comment "sleeping #{how_many} seconds after launching first jenkins job"
        sleep how_many
      end
      idx += 1
    end
    
    successful = []
    failed = []
    dead = []
    
    @op.wait_until("interval" => 30, "timeout" => 3600 * 2) do
      jenkins_jobs.each do |job|
        status = @op.get_build_status("jenkins_job" => job["full_name"], "number" => job["number"])
        job["status"] = status
      end
      
      successful = jenkins_jobs.select do |job|
        status = job["status"]
        ((status["building"].to_s == "false") && (status["result"] == "SUCCESS"))
      end
      
      failed = jenkins_jobs.select do |job|
        status = job["status"]
        status["building"].to_s == "false" &&
        status["result"] == "FAILURE"
      end 
      
      dead = []
      failed.each do |job|
        if job["number"].to_i < 3
          puts "retriggering #{job["full_name"]}"
          job["number"] = @op.trigger_build("jenkins_job" => job["full_name"])
        else
          puts "giving up on #{job["full_name"]}"
          dead << failed.delete(job)
        end
      end
      
      ((successful.size + dead.size) == jenkins_jobs.size)
    end
    
    if successful.size == jenkins_jobs.size
      puts "all jobs completed successfully."
    end
    
    command_name = stack_name + "_post_rollout"
    command = Thread.current['broker'].get_command(command_name)
    
    p = params.clone
    p.delete("stack")
    command.params.each do |cp|
      if (params["extra_params"] || {}).has_key?(cp.name)
        p[cp.name] = params["extra_params"][cp.name]
      end
    end
    p["result"] = {
      :success => successful,
      :failure => dead
    }
    
    @op.send(command_name.to_sym, p)
  end
end
