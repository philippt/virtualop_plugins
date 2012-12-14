description "lists the branches configured for a working copy"

param :machine
param :working_copy

add_columns [ :name, :active ]

on_machine do |machine, params|
  details = machine.working_copy_details("working_copy" => params["working_copy"])
  
  machine.ssh_and_check_result("command" => "cd #{details["path"]} && git branch -a").split("\n").map do |line|
    raise "unexpected output from git branch : >>#{line}<<" unless matched = /(\*)?\s+(.+)/.match(line)
    {
      "name" => matched.captures.last,
      "active" => (matched.captures.first == "*").to_s
    }
  end
end
