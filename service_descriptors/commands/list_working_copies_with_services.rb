description "returns a list like list_working_copies, but adds data about the services contained inside"

param :machine

result_as :list_working_copies

on_machine do |machine, params|
  machine.list_working_copies.each do |working_copy|
    working_copy["services"] = machine.list_services_in_working_copies.select do |candidate|
      candidate["dir_name"] == working_copy["path"]
    end
  end
end
