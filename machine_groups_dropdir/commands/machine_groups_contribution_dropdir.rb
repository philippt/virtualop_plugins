contributes_to :list_machine_groups
result_as :list_machine_groups

execute do |params|
  result = []
  @op.list_machine_groups_dropdir.map do |entry|
    entry["members"].each do |member|
      result << {
        "name" => member,
        "path" => '/' + entry["name"] + '/' + member,
        "parent" => entry["name"]
      }
    end
  end
  result
end