description "retrieves interesting information from a machine"

param :machine

on_machine do |machine, params|
  machine.list_commands_for_crawling.each do |command_name|
    
  end
end