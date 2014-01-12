description "terminates an ec2 instance, rather permanently. you stop paying if you do this."

param :aws_account
param :instance
param "really", "set to 42 if you want something to happen", :default_value => 0

execute do |params|
  # first, find the instance id for the specified name
  morituri = @op.list_all_instances.select do |instance|
    #puts "checking #{instance["name"]} against #{params["instance"]}"
    #pp instance
    instance["tags"]["Name"] == params["instance_name"] &&
    instance["aws_state"] == "running"
  end
  raise "found more than one instance with name #{params["instance"]} - afraid to continue, bailing out." if morituri.size > 1
  raise "found no instance tagged with name '#{params["instance_name"]}'" if 0 == morituri.size
  moriturus = morituri.first
    
  # terminate
  $logger.info "gonna kill #{moriturus["aws_instance_id"]}"
  if params["really"].to_i == 42
    ec2 = @op.get_aws_connection("aws_account" => params["aws_account"])
    termination_states = ec2.terminate_instances([moriturus["aws_instance_id"]])
  
    # TODO wait until it's dead?
    
    # and invalidate
    @op.without_cache do
      candidates = @op.list_all_instances.select do |candidate|
        candidate["name"] == params["instance_name"]
      end
      
      candidates
    end
    
    termination_states
  end
end  