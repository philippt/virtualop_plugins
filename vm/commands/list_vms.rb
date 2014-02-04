description 'returns all virtual machines on a virtualization host'

param :machine

mark_as_read_only

add_columns [ :name, :state ]
#add_columns [ :name, :autostart, :state, :memory, :max_mem, :mem_percent_used, :id, :uuid ]
# TODO cleanup
#@command.result_hints[:column_types] = [ "string", "string", "string", "kilobytes", "kilobytes", "percent", "string", "string", "string" ]

with_contributions do |result, params|
  result
end
