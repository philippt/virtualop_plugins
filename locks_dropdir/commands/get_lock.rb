param! "name", "name/alias for the lock"

accept_extra_params

execute do |params|
  file_name = lock_name_from params
  
  max_attempts = config_string("max_attempts", 10)
  attempt_interval = config_string("attempt_interval_secs", 60)
  attempt_count = 0
  
  result = nil
  
  myself = @op.whoareyou
  
  while (nil == result && attempt_count < max_attempts) do
    attempt_count += 1  
    locks = @op.lock_exists(params)
    if locks.size > 0
      $logger.info "waiting for lock #{file_name} - currently held by #{locks.first["owner"]}"
      sleep attempt_interval
    else
      current_command = Thread.current['broker'].get_command('get_lock')
      
      params["owner"] = myself
      
      full_name = @plugin.state[:drop_dir].write_params_to_file(current_command, params, file_name, ".preparing")
      $logger.info "wrote lock : #{full_name} (#{myself})"
      @op.with_machine("localhost") do |localhost|
        full_name_active = full_name[0..(".preparing".length * -1)-1]
        localhost.ssh("command" => "ls #{full_name_active} || mv #{full_name} #{full_name_active}")
      end
    
      @op.without_cache do
        locks = @op.lock_exists(params)
        if locks.size > 0
          lock = locks.first          
          if lock["owner"] == myself
            result = lock
          else
            $logger.info "was trying to get the lock, looks like #{lock["owner"]} was faster..."
          end
        else
          raise "could not find lock after creating it - weird."
        end
      end
    end
  end
  
  if attempt_count == max_attempts
    raise "could not get lock after #{attempt_count} attempts with #{attempt_interval} second waits, giving up."
  end
  
  result
end