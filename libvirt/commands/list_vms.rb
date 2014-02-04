description 'returns all virtual machines on this host'

param :machine

mark_as_read_only

display_type :table

add_columns [ :name, :state ]
#add_columns [ :name, :autostart, :state, :memory, :max_mem, :mem_percent_used, :id, :uuid ]
# TODO cleanup
#@command.result_hints[:column_types] = [ "string", "string", "string", "kilobytes", "kilobytes", "percent", "string", "string", "string" ]

on_machine do |machine, params|
  result = []

  begin
    count = 0
    machine.ssh("command" => "virsh list --all").split("\n").each do |line|
      count += 1
      next unless count > 2
      matched = /\s*([\d-]+)\s+(\w+)\s+(.+)/.match(line)
      next unless matched
      result << {
        "name" => matched.captures[1],
        "state" => matched.captures[2],
        "full_name" => matched.captures[1] + "." + machine.name
      }
    end

  rescue Exception => e
    $logger.error("could not fetch VM list for host #{params["machine"]} : #{e.message}")
  end

  result
end
