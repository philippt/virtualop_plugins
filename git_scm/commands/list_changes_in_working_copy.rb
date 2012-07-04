description "returns a list of files that have been changed inside this working copy"

mark_as_read_only

param :machine
param :working_copy

display_type :list

on_machine do |machine, params|
  path = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first["path"]
  
  result = []
  
  output = machine.ssh_and_check_result("command" => "cd #{path} && git status")
  output.split("\n").each do |line|
    line.chomp!
    if matched = /#\sOn\sbranch\s(.+)/.match(line)
      $logger.debug "branch: #{matched.captures.first}"
      next
    end
    
    if line == "nothing to commit (working directory clean)"
      result = []
      break  
    end 
       
    result << line
  end
  
  result
end  
