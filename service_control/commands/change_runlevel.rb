description "goes through all services and starts/stops them according to the runlevel specified in the service descriptor"

param :machine
param :runlevel

add_columns [ "service_name", "operation_name", "result" ]

on_machine do |machine, params|
  target_runlevel = params["runlevel"]
    
  result = []
    
  services = machine.status_services.select do |candidate|
    candidate["is_startable"] == true
  end     
    
  infrastructure = services.select { |x| x["runlevel"] == "infrastructure" }
  application = services.select { |x| x["runlevel"] == "application" }
  
  if target_runlevel == "running"
    services = infrastructure + application
  else
    services = application + infrastructure
  end
    
  services.each do |service|
    begin
      h = {
        "service_name" => service["name"],
        "result" => "ok",
        "operation_name" => "unknown"
      }
      
      if service["is_running"] then
        if target_runlevel == "stopped" or
          (target_runlevel == "maintenance" and service["runlevel"] == "application") then

          h["operation_name"] = "stop"
          machine.stop_service("service" => service["full_name"])
          
          result << h
        end
      else
        if params["runlevel"] == "running" or
          (params["runlevel"] == "maintenance" and service["runlevel"] == "infrastructure") then
          
          h["operation_name"] = "start"
          machine.start_service("service" => service["full_name"])
          
          result << h
        end
      end
      
    rescue Exception => e
      h["result"] = "failed (#{e.message})"
      result << h
    end
  end
  #$logger.info "change runlevel result : #{}"
  #p result    
  
  @op.comment "message" => "changed runlevel on #{params["machine"]} to #{params["runlevel"]}"
  
  result
end
