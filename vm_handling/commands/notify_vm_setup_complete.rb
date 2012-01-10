description "notification hook that gets fired when the setup of a new VM has been completed successfully"

param :machine
param! "data"

with_contributions do |result, params|
  #data = params["data"]
  $logger.info "[notification] vm_setup_complete for #{params["machine"]}"
  result
end

