description "contribution base for the machine crawler"

result_as :list_machines

with_contributions do |result, params|
  machines = @op.list_machines
  unknown = result.select { |host|
    not machines.map { |x| x["name"] }.include? host["name"]   
  }.map { |x|
    x["ssh_host"] = x["ssh_name"]
    x
  }
  
  old_list = @op.list_known_machines
  write_known_machine_list(old_list + unknown)
  
  result
end
