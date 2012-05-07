description "lists system groups defined in spacewalk"

param :spacewalk_host

mark_as_read_only

add_columns [ "id", "name", "description", "org_id", "system_count" ]

execute_on_spacewalk do |server, session, params|
  server.call('systemgroup.listAllGroups', session)
end
