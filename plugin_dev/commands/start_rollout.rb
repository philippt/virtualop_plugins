param! "host", "a host to rollout the stack on"
param! "stack", "the stack name"

accept_extra_params

execute do |params|
  @op.load_dev_plugin
  
  params["machine"] = params["host"]
  params.delete("host")
  @op.trigger_stack_rollout(params)
end