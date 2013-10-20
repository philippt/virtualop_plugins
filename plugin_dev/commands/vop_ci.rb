description "tests if a vop machine can setup new machines"

param! "host", "a host to run CI on"
param "default_user", "default SSH user"
param "default_password", "default SSH password"

execute do |params|
  @op.find_vms
  
  @op.load_dev_plugin
  
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org",
    "default_user" => params["default_user"],
    "default_password" => params["default_password"] 
  })  
end