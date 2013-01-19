description "sounds funny, but it ain't."

param :machine
param "really", "set to true unless you're just kidding", :lookup_method => lambda { %w|true false| }, :default_value => "false"

result_as :list_known_machines

on_machine do |machine, params|
  installed = machine.list_installed_vms.map do |vm|
    vm["full_name"] = vm["vm_name"] + "." + machine.name
    vm
  end
  maybes = @op.list_known_machines.select do |x|
    x["type"] == "vm" and
    x["host_name"] == machine.name
  end
  
  morituri = []
  maybes.each do |maybe|
    unless installed.select { |x| x["full_name"] == maybe["name"] }.size > 0
      morituri << maybe
    end    
  end
  
  if params.has_key?("really") and params["really"] == "true"
    morituri.each do |moriturus|
      @op.remove_known_machine("name" => moriturus["name"])
    end
  end
  
  morituri
end
