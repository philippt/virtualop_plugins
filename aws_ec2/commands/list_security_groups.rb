description "returns a list of security groups defined for this account"

param :aws_account

mark_as_read_only

#display_type :table
add_columns %w|aws_group_name aws_description aws_owner|

execute do |params|
  ec2 = @op.get_aws_connection(params)
        
  result = []
  ec2.describe_security_groups.each do |group_hash|
    h = {}
    group_hash.each do |k,v|
      h[k.to_s] = v
    end
    #p h
    result << h
  end
  result
end