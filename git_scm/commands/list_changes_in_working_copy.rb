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
  
  # TODO in some cases, this seems to return status 1 even if everything's more or less normal:
  # sbk-vop-test:~/service_descriptors # git status
  # # On branch master
  # nothing to commit (working directory clean)
  # sbk-vop-test:~/service_descriptors # echo $?
  # 1
  #output = machine.ssh("command" => "cd #{path} && git status")
  output = machine.ssh("command" => "cd #{path} && git status")
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
