description "tests if a vop machine can setup new machines"

param! "host", "a host to run CI on"

execute do |params|
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org" 
  })
end