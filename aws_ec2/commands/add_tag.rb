description "adds a tag to the specified instance"

param :aws_account
param! :instance_id
param! "key", "the key name for the tag"
param! "value", "the value for the tag"

execute do |params|
  ec2 = @op.get_aws_connection("aws_account" => params["aws_account"])
  ec2.create_tag(params["aws_instance_id"], params["key"], params["value"])
  
  # TODO actually, we don't want to work completely without cache, a temporary cache flush would be nice
  @op.without_cache do
    @op.list_tags_for_instance("aws_account" => params["aws_account"], "aws_instance_id" => params["aws_instance_id"])
    @op.list_all_instances      
  end
end