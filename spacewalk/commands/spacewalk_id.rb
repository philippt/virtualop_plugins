description "returns the spacewalk id associated to this machine"

param :machine

mark_as_read_only

on_machine do |machine, params|
  @op.spacewalk_list_machines.select { |x| x["name"] == machine.name }.map { |x| x["id"] }.first
end
