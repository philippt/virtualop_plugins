description "notification hook that gets fired when the setup of a new VM is being started"

param "machine_name"
param! "data"

with_contributions do |result, params|
  $logger.info "[notification] vm_setup_start for #{params["machine_name"]}"
  result
end

