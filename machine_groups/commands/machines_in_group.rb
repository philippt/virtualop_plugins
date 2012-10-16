description "returns all machines that can be found in the specified machine group or it's children"

param :machine_group

result_as :list_machines

execute do |params|
  result = []
  
  machines = @op.list_machines.select { |x| x["name"] == params["machine_group"] }
  
  if machines.size > 0
    result = machines
  end
  
  @op.list_machine_group_children("machine_group" => params["machine_group"]).each do |child|
    result += @op.machines_in_group("machine_group" => child["name"]) 
  end
  
  result
end
