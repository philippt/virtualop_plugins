description "returns a list like list_working_copies, but adds data about the services contained inside"

param :machine

result_as :list_working_copies

mark_as_read_only

on_machine do |machine, params|
  machine.list_working_copies.each do |working_copy|
    services = machine.list_services_in_working_copies.select do |candidate|
      candidate["dir_name"] == working_copy["path"]
    end    
    project_name = working_copy["project"].split("/").last
    same_name = services.select { |x| x["full_name"] == (project_name + '/' + project_name) }
    if same_name.size > 0    
      services.unshift services.delete same_name.first
    end
    
    working_copy["services"] = services
  end
end