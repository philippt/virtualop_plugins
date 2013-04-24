param :machine

add_columns [ :alias, :name ]

mark_as_read_only

on_machine do |machine, params|
  idx = 0
  result = []
  machine.ssh("command" => "zypper lr").split("\n").map do |x|
    idx += 1    
    next unless idx > 2    
    cols = x.split("|")    
    result << {
      "alias" => cols[1].strip,
      "name" => cols[2].strip
    }
  end
  result
end				
