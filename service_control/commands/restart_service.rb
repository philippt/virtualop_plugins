description "stops a service and starts it again"

param :machine
param :service

on_machine do |machine, params|
  machine.stop_service(params)
  machine.start_service(params)
end
