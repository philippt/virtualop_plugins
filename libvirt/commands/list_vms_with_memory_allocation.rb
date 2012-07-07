description "returns a list of virtual machines with the memory they could theoretically use if they wanted to"

param :machine

add_columns [ :name, :memory, :memory_percent ]
@command.result_hints[:column_types] = [ "string", "kilobytes", "percent" ]

mark_as_read_only

on_machine do |machine, params|
  total = machine.meminfo["MemTotal"]
  machine.list_vms.map do |vm|
    # TODO extract
    dominfo = machine.ssh_and_check_result("command" => "virsh dominfo #{vm["name"]}")
    dominfo.split("\n").each do |line|
      if matched = /Max memory:\s+(\d+)\s+kB/.match(line)
        memory = matched.captures.first
        vm["memory"] = memory
        vm["memory_percent"] = memory.to_i / (total.to_i / 100)
      end
    end
    vm
  end  
end
