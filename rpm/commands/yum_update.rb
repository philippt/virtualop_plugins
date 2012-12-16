description 'invokes yum update to upgrade all installed system packages'

param :machine

on_machine do |machine, params|
  begin
    machine.ssh_and_check_result("command" => "yum -y update 2>&1 > /var/log/yum_update.log")
  rescue => error
    if /Thread died in Berkeley DB library/.match(error.message)
      # http://forums.fedoraforum.org/showthread.php?t=209092
      [
        "rm /var/lib/rpm/__db.0*",
        "rpm --rebuilddb",
        "yum clean all",
        "yum check-update",
        "yum update"
      ].each do |command|
        machine.ssh_and_check_result("command" => command)
      end
    else
      raise error
    end
  end
end
