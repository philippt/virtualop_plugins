description "subscribes the current machine to the specified configuration channel. the new channel is added to the top of the configured channels list"

param :spacewalk_host
param :machine
param :config_channel

execute_on_spacewalk do |server, session, params|
  spacewalk_id = @op.spacewalk_list_machines.select { |x| x["name"] == params["machine"] }.map { |x| x["id"] }.first
  server.call('system.config.addChannels', session, 
      [ spacewalk_id ],
      [ params["config_channel"] ],
      true
    )
end