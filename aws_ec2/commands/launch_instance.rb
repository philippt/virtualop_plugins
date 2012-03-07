description "launches a new AWS instance"

result_type_aws_instances

param :aws_account
param! "name", "name for the new instance"
param! "key_name", "name of the keypair to use", 
  :lookup_method => lambda { |request|
      @op.list_key_pairs("aws_account" => request.get_param_value("aws_account")).map do |key_pair|
        key_pair["aws_key_name"]
      end
  }
param! "availability_zone", "the availability zone into which the new instance should be placed", 
  :lookup_method => lambda { |request|
      @op.list_availability_zones("aws_account" => request.get_param_value("aws_account")).map do |zone|
        zone["zone_name"]
      end
  }
param! "instance_type", "the virtual hardware dimensioning of the new instance.", :default_value => "t1.micro"
param! "ami", "the AMI to use"
param! "security_groups", "the security groups to which this instance should be assigned", :allows_multiple_values => true,
  :lookup_method => lambda { |request| 
    @op.list_security_groups("aws_account" => request.get_param_value("aws_account")).map do |group|
      group["aws_group_name"]
    end    
  }
            
execute do |params|
  ec2 = @op.get_aws_connection("aws_account" => params["aws_account"])
  
  launched_instances = ec2.launch_instances(params["ami"], 
    :key_name => params["key_name"], 
    :availability_zone => params["availability_zone"],
    :instance_type => params["instance_type"],  # "t1.micro",
    :group_ids => params["security_groups"] #groups.split(",")  # [ "rn", "puppets" ]
  )
  result = []
  launched_instances.each do |hash|
    h = {}
    hash.each do |k,v|
      h[k.to_s] = v
    end

    result << h
  end
  
  new_instance_id = result.first["aws_instance_id"]
  $logger.info "launched new instance with id '#{new_instance_id}'"
  
  
  # refresh the instance list so that we can set the name tag 
  # TODO bit ugly, that logic
  sleep 1
  @op.without_cache do
    candidates = @op.list_all_instances.select do |candidate|
      candidate["aws_instance_id"] == new_instance_id
    end
    raise "could not find newly created instance with id '#{new_instance_id}' in instance list. something's wrong." if candidates.size == 0
  end
  
  # set the name
  @op.add_tag(
    "aws_account" => params["aws_account"], 
    "aws_instance_id" => new_instance_id,
    "key" => "Name",
    "value" => params["name"]
  )
  
  
  # TODO wait until it's launched
  @op.without_cache do
    @op.list_all_instances
  end
  
  result
end
