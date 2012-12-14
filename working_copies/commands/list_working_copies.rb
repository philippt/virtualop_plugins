description "working copies are projects living on machines"

param :machine

mark_as_read_only

add_columns [ :path, :name, :type ]

with_contributions do |result, params|
  result  
end  
