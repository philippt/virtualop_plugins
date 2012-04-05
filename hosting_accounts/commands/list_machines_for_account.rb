description 'returns all machines that can be found within an hosting account'

param :hosting_account

result_as :list_machines
mark_as_read_only

execute do |params|
  @op.list_machines.select do |machine|
    machine["account"] == params["hosting_account"]
  end
end
