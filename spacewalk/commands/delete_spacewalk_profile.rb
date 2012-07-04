description "deletes all spacewalk profiles found for a machine"

param :spacewalk_host
param :machine

execute_on_spacewalk do |server, session, params|
  ids = @op.spacewalk_list_machines.select { |x| x["name"] == params["machine"] }.map { |x| x["id"] }
  result = server.call('system.deleteSystems', session, ids) == 1
  
  @op.without_cache do
    @op.spacewalk_list_machines
  end
  result
end  



