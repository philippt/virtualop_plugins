description 'returns a list of entries (e.g. machines, hosts, instances) configured through the selected account.'

param :hosting_account

mark_as_read_only

add_columns [ :name ]

execute do |params|
  account = @op.list_hosting_accounts.select do |acct|
    acct["alias"] == params["hosting_account"]
  end.first
  
  # TODO could be nicer
  case account["type"]
  when "aws" 
    @op.list_instances("aws_account" => params["hosting_account"])
  when "hetzner"
    @op.list_hetzner_entries("hetzner_account" => params["hosting_account"])
  end  
end
