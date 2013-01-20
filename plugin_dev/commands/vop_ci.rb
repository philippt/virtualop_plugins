description "tests if a vop machine can setup new machines"

param! "host", "a host to run CI on"

execute do |params|
  @op.find_vms
  
  #params["host"] = 'zapata.virtualop'
  
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.load_plugin("machine" => "localhost", "plugin_file_name" => "/root/virtualop_plugins/plugin_dev/plugin_dev.plugin")
  
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org" 
  })  
end