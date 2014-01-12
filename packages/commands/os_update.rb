param :machine

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "centos"
    machine.yum_update(params)    
  else
    raise "not yet implemented, sorry."
  end
end
