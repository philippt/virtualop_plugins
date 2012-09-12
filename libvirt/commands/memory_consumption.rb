description "returns statistics about how much memory is consumed by VMs on this host"

param :machine

mark_as_read_only

display_type :hash

on_machine do |machine, params|
  mem_used = 0
  machine.list_vms_with_memory_allocation.each do |row|
    mem_used += row["memory"].to_i
  end
  
  mem_total = machine.meminfo["MemTotal"].to_i
  buffer = 1024 * 1024
  mem_usable = mem_total - buffer
  mem_free = mem_usable - mem_used
  
  {
    "total" => mem_total,
    "used" => mem_used,
    "used_percent" => mem_used / (mem_total / 100),
    "buffer" => buffer,
    "free" => mem_free,
    "free_percent" => mem_free / (mem_usable / 100) 
  }
end
