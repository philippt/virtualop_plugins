add_columns [ :plugin, :name ]

execute do |params|
  result = []
  @plugin.state[:stacks].each do |plugin, stacks|
    result += stacks.map do |stack|
      stack["plugin"] = plugin
      stack
    end
  end
  result
end
