description "lists all machines that belong to a given system group"

param :spacewalk_host
param :spacewalk_system_group

mark_as_read_only

add_columns [ "hostname", "release", "osa_status"]

execute_on_spacewalk do |server, session, params|
  server.call('systemgroup.listSystems', session, params["spacewalk_system_group"])
end