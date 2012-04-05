description "terminates an ec2 instance, rather permanently. you stop paying if you do this."

param :aws_account
param :instance

execute do |params|
  # first, find the instance id for the specified name
  morituri = @op.list_all_instances.select do |instance|
    #puts "checking #{instance["name"]} against #{params["instance"]}"
    instance["name"] == params["instance_name"] and
    instance["aws_state"] == "running"
  end
  raise "found more than one instance with name #{params["instance"]} - afraid to continue, bailing out." if morituri.size > 1
  moriturus = morituri.first
  
  
  # terminate
  ec2 = @op.get_aws_connection("aws_account" => params["aws_account"])
  #puts "gonna kill #{moriturus["aws_instance_id"]}"
  termination_states = ec2.terminate_instances(moriturus["aws_instance_id"])

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