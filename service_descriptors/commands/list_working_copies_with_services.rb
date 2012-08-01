description "returns a list like list_working_copies, but adds data about the services contained inside"

param :machine

result_as :list_working_copies

mark_as_read_only

on_machine do |machine, params|
  machine.list_working_copies.each do |working_copy|
    services = machine.list_services_in_directory("directory" => working_copy["path"])
    working_copy["services"] = services
  end
end
