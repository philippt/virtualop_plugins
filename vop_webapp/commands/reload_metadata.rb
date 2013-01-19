description "reloads which tabs and actions to display for a machine"

param :machine

on_machine do |machine, params|
  @op.without_cache do
    machine.list_machine_actions
    machine.list_machine_tabs
  end
end
