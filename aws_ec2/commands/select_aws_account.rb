description "pre-selects an AWS account to work with"

param :aws_account

execute_request do |request, response|
  response.set_context('aws_account' => request.get_param_value("aws_account"))
end
  