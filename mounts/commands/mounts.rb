description "lists mounts on a machine"

param :machine

add_columns [ :target, :path, :type ]

mark_as_read_only

on_machine do |machine, params|
  result = []
  
  machine.ssh("mount").split("\n").each do |line|
    if matched = /(.+)\s+on\s+(.+)\s+type\s+(.+)\s+\((.+)\)/.match(line)
      result << {
        "target" => matched.captures[0],
        "path" => matched.captures[1],
        "type" => matched.captures[2],
        "options" => matched.captures[3]
      }
    end
  end
  
  result
end
