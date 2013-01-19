description "retrieves interesting information from a machine"

param :machine

on_machine do |machine, params|
  if machine.reachable_through_ssh == "true"  
    machine.list_commands_for_crawling.each do |command_name|
      $logger.info "+++ #{command_name} on #{machine.name}"
      # TODO error-handling
      machine.send(command_name.to_sym)
    end
  end
end