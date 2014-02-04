description "returns a list of all packages installed through apt"

param :machine

display_type :table

add_column :name
add_column :version
add_column :description

contributes_to :list_packages

available_if do |params|
  @op.with_machine(params["machine"]) do |machine|
    machine.linux_distribution.split("_").first == "ubuntu"
  end
end

on_machine do |machine, params|
  result = []
  # TODO hardcoded sudo
  output = machine.ssh("command" => "sudo dpkg -l")
  
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