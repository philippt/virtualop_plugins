param :machine

param "count", "number of spares that should be available", :default_value => 5

display_type :list

on_machine do |machine, params|
  existing = machine.list_vms.map { |x| x["name"] }
  
  result = []
  1.upto(params["count"].to_i) do |idx|
    vm_name = "spare#{sprintf('%02d', idx)}"
        
    machine.setup_vm("vm_name" => vm_name, "keep_proxy" => true) unless existing.include? vm_name
    result << vm_name
  end
  
  result
end
