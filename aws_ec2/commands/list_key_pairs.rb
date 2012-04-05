description "returns a list of all available key pairs in the selected aws account"

param :aws_account

mark_as_read_only

add_columns [ "aws_key_name", "aws_fingerprint" ]

execute do |params|
  ec2 = @op.get_aws_connection(params)
    
  result = []
  ec2.describe_key_pairs().each do |aws_hash|
    h = {}
    aws_hash.each do |k,v|
      h[k.to_s] = v
    end      
    result << h
  end
  
  result
end
