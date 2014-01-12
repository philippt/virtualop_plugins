description "returns a list of virtual machines with the memory they could theoretically use if they wanted to"

param :machine

add_columns [ :name, :memory, :memory_percent ]
@command.result_hints[:column_types] = [ "string", "kilobytes", "percent" ]

mark_as_read_only

on_machine do |machine, params|
  result = []
  
  total = machine.meminfo["MemTotal"]
  machine.list_vms.each do |vm|
    next unless vm["state"] == "running"
    # TODO extract    
    dominfo = machine.ssh("command" => "virsh dominfo #{vm["name"]}")
    dominfo.split("\n").each do |line|
      if matched = /Used memory:\s+(\d+)\s+[kK](?:i?)B/.match(line)
        memory = matched.captures.first
        vm["memory"] = memory
        vm["memory_percent"] = memory.to_i / (total.to_i / 100)
        result << vm.clone()
      else
        #$logger.warn "could not parse memory info for VM '#{vm["name"]}'"
      end
    end
  end  
  
  result
end
