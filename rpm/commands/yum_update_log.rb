description 'returns the last lines of the yum update log'

param :machine

display_type :list

on_machine do |machine, params|
  result = []
  log_name = "/var/log/yum_update.log"
  if machine.file_exists("file_name" => log_name)
    result += machine.ssh_and_check_result("command" => "tail /var/log/yum_update*.log").split("\n")
  end
  result
end
