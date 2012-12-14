description "helper that returns the children of a machine group"

#param! "parent", "the group for which children should be looked up"
param :machine_group

add_columns [ :name, :parent ]

mark_as_read_only

execute do |params|
  @op.list_machine_groups.select do |row|
    row["parent"] == params["machine_group"]
  end
end



