description 'selects one of a list of hetzner accounts to work with'

param :hetzner_account_without_context

execute_request do |request, response|
  response.set_context('hetzner_account' => request.get_param_value('hetzner_account'))
end
