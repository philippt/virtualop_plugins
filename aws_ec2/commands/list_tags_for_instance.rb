description "returns all tags associated to the specified instance"

param :aws_account
param! :instance_id

mark_as_read_only

add_columns [ "key", "value" ]

execute do |params|
  instance = @op.list_instances("aws_account" => params["aws_account"]).select do |instance|
    instance["aws_instance_id"] == params["aws_instance_id"]
  end.first
  
  result = []
  instance["tags"].each do |k,v|
    result << {
      "key" => k,
      "value" => v
    }
  end
  result
end