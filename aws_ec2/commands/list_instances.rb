description 'returns a list of known ec2 instances'

param :aws_account

mark_as_read_only
add_columns [ "name", "type", "env", "aws_instance_id", "aws_instance_type", "aws_state", "dns_name" ]

execute do |params|
  ec2 = @op.get_aws_connection(params)

  result = []
  ec2.describe_instances().each do |instance_hash|
    h = {}
    instance_hash.each do |k,v|
      h[k.to_s] = v
      $logger.debug("instance hash : '#{k}' => '#{v}'")
    end
    h["aws_account"] = params["aws_account"]
    h["account"] = params["aws_account"]
    if h["tags"].has_key?("Name")
      instance_name = h["tags"]["Name"]      
    else
      instance_name = h["aws_instance_id"]
    end    
    h["name"] = "#{instance_name}.#{params["aws_account"]}"
    
    h["ssh_name"] = h["dns_name"]
    h["ssh_user"] = "ubuntu" # TODO config
    h["ssh_key_name"] = "/etc/vop/aws_accounts.d/#{h["ssh_key_name"]}.pem" 
    
    h["type"] = "vm" 
    result << h
  end
  result
end