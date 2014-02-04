description "assembles a tree out of spacewalk machine groups"

mark_as_read_only

add_columns [ :name, :parent ]

contributes_to :list_machine_groups

execute do |params|
  result = []
  
  sw_alias = "bettermarks"
  result << {
    "parent" => nil,
    "name" => sw_alias
  }
  
  @op.list_system_groups.each do |group|
    result << {
      "parent" => sw_alias,
      "name" => group["name"]
    }
    @op.list_machines_in_system_group("spacewalk_system_group" => group["name"]).each do |machine|
      result << {
        "parent" => group["name"],
        "name" => machine["hostname"]
      }
    end
  end
  result
end
