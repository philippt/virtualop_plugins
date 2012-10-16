description "selects a spacewalk instance to work with"

param :spacewalk_host

execute_request do |request, response|
  response.set_context('spacewalk_host' => request.get_param_value('spacewalk_host'))
end
