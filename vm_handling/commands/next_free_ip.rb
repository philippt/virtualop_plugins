description 'returns the next available IP on this host'

param :machine

on_machine do |machine, params|
  
  installed_vms = machine.list_installed_vms
  
  if installed_vms.size > 0
    idx = 2
    ip_to_use = nil
    
    while (ip_to_use == nil and idx < 256)
      candidate = "10.60.10.#{idx}"
      
      unless installed_vms.map { |x| x["ipaddress"].to_s }.include? candidate
        ip_to_use = candidate
        break
      else
        idx += 1
      end
    end
    
    raise "no free ip address found" if ip_to_use == nil
    ip_to_use
  else
    "10.60.10.2"
  end
end
