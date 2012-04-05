description 'configures a new aws account'

mark_as_read_only

result_type_aws_accounts

param! "alias", "a human-readable alias name to describe this account. should also be a valid unix file name (sorry)"
param! "access_key_id", "the access key id for this account as provided by aws"
param! "secret_access_key", "the secret key for this account"
param! "aws_region", "the aws region in which this account can be found"

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
    
  # check if the account has been created and return it
  @op.without_cache do 
    candidates = @op.list_aws_accounts.select do |candidate|
      candidate["alias"] == params["alias"]
    end
    raise "did not find account after creating it, weird." if candidates.size == 0
    candidates
  end
end
