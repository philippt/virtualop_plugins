description "returns a list of all packages installed through apt"

param :machine

display_type :table
add_column :name
add_column :version
add_column :description

on_machine do |machine, params|
  result = []
  # TODO hardcoded sudo
  output = machine.ssh_and_check_result("user" => "root", "command" => "dpkg -l")
  
  output.split("\n").each do |line|
    matched = /^(\w{2})\s+(\S+)\s+(\S+)\s+(.+)$/.match(line)
    if matched
      result << {        
        "name" => matched.captures[1],
        "version" => matched.captures[2],
        "description" => matched.captures[3]
      }
      # TODO should include the status fields (captures[0])
    end
  end
  result
end