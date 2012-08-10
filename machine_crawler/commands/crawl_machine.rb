description "retrieves interesting information from a machine"

param :machine

on_machine do |machine, params|
  machine.list_commands_for_crawling.each do |command_name|
    $logger.info "+++ #{command_name} on #{machine.name}"
    machine.send(command_name.to_sym)
  end
end