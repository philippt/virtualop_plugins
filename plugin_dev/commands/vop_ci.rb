description "tests if a vop machine can setup new machines"

param! "host", "a host to run CI on"

execute do |params|
  @op.find_vms
  
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.with_machine("localhost") do |localhost|
    localhost.load_plugin("plugin_file_name" => "#{localhost.home}/virtualop_plugins/plugin_dev/plugin_dev.plugin")
  end
  
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org" 
  })  
end