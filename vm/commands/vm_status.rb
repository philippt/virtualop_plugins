param :machine

execute do |params|
  result = "unknown"
  machine_detail = @op.machine_detail(params)
  if "vm" == machine_detail["type"] 
    machine_name = params["machine"]
    host_name = machine_detail["host_name"]
    begin
      vm_status = @op.list_vms("machine" => host_name).select do |x| 
        x.has_key?("full_name") && x["full_name"] == machine_name 
      end.first
      
      #vm_exists = nil != vm_status
      if nil == vm_status
        result = "missing"
      else
        result = vm_status["state"]
      end 
    rescue => detail
      $logger.warn("hit a problem while trying to find machine '#{machine_name}' in vm list on host '#{host_name}' : #{detail.message}")
    end
  end
  result  
end
