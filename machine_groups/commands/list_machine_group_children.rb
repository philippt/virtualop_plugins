description "helper that returns the children of a machine group"

param :machine_group, "", :default_param => true
param "recursive", "set to a value x > 0 to fetch x level of children", :default_value => 0

add_columns [ :name, :parent ]

mark_as_read_only

execute do |params|
  result = @op.list_machine_groups.select do |row|
    row["parent"] == params["machine_group"]
  end
  if params["recursive"].to_i > 0
    more = []
    result.each do |child|
      more += @op.list_machine_group_children("machine_group" => child["name"], "recursive" => params["recursive"].to_i - 1)
    end
    result += more
  end
  result
end



