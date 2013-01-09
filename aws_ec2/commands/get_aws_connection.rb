description "returns a AWS connection for the specified account"

param :aws_account

execute do |params|
  aws_account = @op.list_aws_accounts.select do |account|
    account["alias"] == params["aws_account"]
  end.first
  aws_options = {
    :region => aws_account["aws_region"],
    :connection_mode => :per_request
  }    
  aws_access_key_id = aws_account["access_key_id"]
  aws_secret_access_key = aws_account["secret_access_key"]
  Aws::Ec2.new(aws_access_key_id, aws_secret_access_key, aws_options.clone())
end
