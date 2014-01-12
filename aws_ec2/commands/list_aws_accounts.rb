description 'lists all configured aws accounts'

mark_as_read_only
#result_type_aws_accounts(@command)
add_columns [ "alias", "access_key_id", "secret_access_key", "aws_region" ]

contributes_to :list_hosting_accounts

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir.map do |account|
    account["type"] = "aws"
    account
  end
end
