def param_aws_account(options = {})
  param_aws_account_without_context(:autofill_context_key => "aws_account")
end

def param_aws_account_without_context(options = {})
  merge_options_with_defaults(options, 
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_aws_accounts.map do |account|
        account["alias"]
      end
    end
  )
  RHCP::CommandParam.new("aws_account", "the aws account that should be used by default", options)
end

def param_instance(options = {})
  merge_options_with_defaults(options,
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_all_instances.map do |instance|
        instance["tags"]["Name"]
      end
    end
  )
  RHCP::CommandParam.new("instance_name", "the name of the instance to work with", options)
end

def param_instance_id(options = {})
  merge_options_with_defaults(options,
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_all_instances.map do |instance|
        instance["aws_instance_id"]
      end
    end
  )
  RHCP::CommandParam.new("aws_instance_id", "the aws instance ID of the instance to work with", options)
end

def result_type_aws_instances
  add_columns [ "name", "type", "env", "aws_instance_id", "aws_instance_type", "aws_state", "dns_name" ]
end

def result_type_aws_accounts
  add_columns [ "alias", "access_key_id", "secret_access_key", "aws_region" ]
end