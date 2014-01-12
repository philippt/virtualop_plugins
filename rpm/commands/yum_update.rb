description 'invokes yum update to upgrade all installed system packages'

param :machine

on_machine do |machine, params|
  # there might be already a yum process running - started by the OS
  @op.wait_until(
    "interval" => 5, "timeout" => 120, 
    "error_text" => "there seems to be a yum process already running") do
    result = false
    begin
      result = machine.processes_like("string" => "yum").size == 0
    rescue Exception => e
      $logger.info("got an exception while trying to connect to machine : #{e.message}")
    end
    result
  end
   
  MAX_ATTEMPTS = 3
  YUM_UPDATE_TIMEOUT_MIN = config_string('yum_update_timeout_min', 15)
  attempts = 0
  updated = false
  while (attempts < MAX_ATTEMPTS) and not updated do
    attempts += 1    
    begin
      Timeout::timeout(YUM_UPDATE_TIMEOUT_MIN * 60) {
        begin
          machine.ssh("command" => "yum -y update 2>&1 > /var/log/yum_update_#{attempts}.log")
        rescue => error
          # TODO [note to sober self] this sounds horribly self-inflicted
          if /Thread died in Berkeley DB library/.match(error.message)
            # http://forums.fedoraforum.org/showthread.php?t=209092
            [
              "rm /var/lib/rpm/__db.0*",
              "rpm --rebuilddb",
              "yum clean all",
              "yum check-update",
              "yum update"
            ].each do |command|
              machine.ssh("command" => command)
            end
          else
            raise error
          end
        end        
        
        updated = true
      }
    rescue => detail
      $logger.warn "yum update didn't complete within #{YUM_UPDATE_TIMEOUT_MIN} minutes - #{MAX_ATTEMPTS - attempts} attempts left.."
      machine.kill_processes_like("string" => "yum")
    end
  end
    
  if updated
    @op.comment("message" => "OS package update complete (took #{attempts} attempt(s)).")
  else
    raise "couldn't update OS packages"
  end
end
