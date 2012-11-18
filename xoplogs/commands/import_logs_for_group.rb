description "imports logfiles from all machines in the selected machine group"

param :machine_group

execute do |params|
  @op.machines_in_group(params).each do |machine|
    @op.import_logs("machine" => machine["name"])
  end
end
