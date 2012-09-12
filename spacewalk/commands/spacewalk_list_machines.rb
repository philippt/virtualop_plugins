description "returns all machines registered in spacewalk"

add_columns [ "name", "id", "type", "env" ]

param :spacewalk_host

contributes_to :list_machines

execute_on_spacewalk do |server, session, params|
  server.call('system.listUserSystems', session).map do |system|
    {
      "name" => system["name"],
      "id" => system["id"],
    }
  end
end  