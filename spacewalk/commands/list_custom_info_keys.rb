description "list the custom information keys defined for the user’s organization."

param :spacewalk_host

mark_as_read_only

add_columns [ "id", "label", "description", "system_count", "last_modified" ]

execute_on_spacewalk do |server, session, params|
  server.call('system.custominfo.listAllKeys', session)
end