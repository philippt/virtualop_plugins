description "selects the data repository to work with"

param :data_repo_without_context, :autofill_context_key => nil

execute_request do |request, response|
  response.set_context('data_repo' => request.get_param_value('data_repo'))
end  
