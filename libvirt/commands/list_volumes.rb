param :machine

add_columns [ :name, :path ]

on_machine do |machine, params|
  idx = 0
  result = []
  
  machine.ssh("command" => "virsh vol-list --pool default").split("\n").each do |line|
    idx += 1
    next unless idx > 1
    
    if matched = /(\S+)\s+(.+)/.match(line)
      result << {
        "name" => matched.captures[0],
        "path" => matched.captures[1] 
      }
    end
  end
  
  result
end