description "stops a service and starts it again"

param :machine
param :service, "", :default_param => true
param "delay", "seconds to wait between stop and start", :default_value => 2

on_machine do |machine, params|
  delay = params["delay"].to_i
  params.delete("delay")
  machine.stop_service(params) if machine.status_service(params) == "true"
  sleep delay
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
