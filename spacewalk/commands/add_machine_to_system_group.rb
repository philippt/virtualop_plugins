description "add the machine to a given system group"

param :spacewalk_host
param :machine
param :system_group

execute_on_spacewalk do |server, session, params|
  @op.with_machine(params["machine"]) do |machine|
    $logger.info "adding '#{machine.name}' to system group '#{ params["system_group"] }'"
    server.call('systemgroup.addOrRemoveSystems', session, 
      params["system_group"],
      [ machine.spacewalk_id ],
      true
    )
  end     
end