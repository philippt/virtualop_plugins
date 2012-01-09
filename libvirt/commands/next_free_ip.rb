description 'returns the next available IP on this host'

param :machine

on_machine do |machine, params|
  
  installed_vms = machine.list_installed_vms
  
  if installed_vms.size > 0
    highest_used_ip = installed_vms.sort_by { |x| x["ipaddress"].split(".").last.to_i }.last["ipaddress"]
    
    parts = highest_used_ip.split(".")
    
    parts << parts.pop.to_i + 1
    parts.join(".")
  else
    "10.60.10.2"
  end
end
