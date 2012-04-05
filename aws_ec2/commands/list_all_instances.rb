description "returns all instances from all configured AWS accounts"

mark_as_read_only

#result_type_aws_instances(@command)
add_columns [ "name", "type", "env", "aws_instance_id", "aws_instance_type", "aws_state", "dns_name" ]

contributes_to :list_machines

execute do |params|
  result = []
  @op.list_aws_accounts.each do |aws_account|
    result += @op.list_instances("aws_account" => aws_account["alias"])
  end
  result
end
