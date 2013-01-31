description "stops a service and starts it again"

param :machine
param :service

on_machine do |machine, params|
  machine.stop_service(params)
  sleep 1
  machine.start_service(params)
  
  details = machine.service_details("service" => params["service"])
  if details.has_key? "post_restart"
    @op.without_cache do
      details = machine.service_details("service" => params["service"])
    end
    begin
        details["post_restart"].call(machine, params)
    rescue => detail
      raise "problem in post_restart block for service #{params["service"]} on #{params["machine"]} : #{detail.message}"
    end
  end
end
