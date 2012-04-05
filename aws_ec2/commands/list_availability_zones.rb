description "returns a list with all availability zones defined by AWS"

param :aws_account

mark_as_read_only

add_columns %w|region_name zone_name zone_state|

execute do |params|
  ec2 = @op.get_aws_connection(params)
        
  result = []
  ec2.describe_availability_zones.each do |instance_hash|
    h = {}
    instance_hash.each do |k,v|
      h[k.to_s] = v
    end
    result << h
  end
  result
end
