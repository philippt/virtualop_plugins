description "lists the branches configured for a working copy"

param :machine
param :working_copy

add_columns [ :name, :active ]

on_machine do |machine, params|
  path = machine.list_working_copies.select { |x| x["name"] == params["working_copy"] }.first["path"]
  #details = machine.working_copy_details("working_copy" => params["working_copy"])
  
  machine.ssh("command" => "cd #{path} && git branch -a").split("\n").map do |line|
    raise "unexpected output from git branch : >>#{line}<<" unless matched = /(\*)?\s+(.+)/.match(line)
    {
      "name" => matched.captures.last.chomp,
      "active" => (matched.captures.first == "*").to_s
    }
  end
end
