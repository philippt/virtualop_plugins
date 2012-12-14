description "pre-selects an ldap server and stores that selection in the context"

param :ldap_server_without_context

execute_request do |request, response|
  response.set_context('ldap_server' => request.get_param_value('ldap_server'))
end