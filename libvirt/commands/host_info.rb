description "returns information about a virtualization host (libvirt: virNodeInfo)"

param :machine

mark_as_read_only
add_columns [ :cpus, :model, :mhz, :memory, :cores ]

on_machine do |machine, params|
  result = []
  machine.with_libvirt do |conn|
    node_info = conn.node_get_info
    result << {
      "cpus" => node_info.cpus,
      "model" => node_info.model,
      "mhz" => node_info.mhz,
      "memory" => node_info.memory,
      "cores" => node_info.cores
    }
  end
  result
end    
