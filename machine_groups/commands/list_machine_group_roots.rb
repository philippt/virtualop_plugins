description "returns the root nodes of the machine group tree"

mark_as_read_only

add_columns [ :path, :name, :parent ]

contributes_to :list_inventory_items

execute do |params|
  @op.list_machine_groups.select { |x| x["path"].split("/").size == 2 }
end
