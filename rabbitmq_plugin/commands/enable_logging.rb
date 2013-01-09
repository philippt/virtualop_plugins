execute_request do |request, response|
  response.set_context('logging_enabled' => 'true')
end
