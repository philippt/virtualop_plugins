description "retrieves interesting information from a machine"

param :machine

on_machine do |machine, params|
  if machine.reachable_through_ssh
    machine.list_commands_for_crawling.each do |command_name|
      begin
        $logger.info "+++ #{command_name} on #{machine.name}"
        # TODO error-handling
        machine.send(command_name.to_sym)
      rescue => detail
        $logger.warn "had a problem executing #{command_name} : #{detail.message}"
      end
    end
  end
end