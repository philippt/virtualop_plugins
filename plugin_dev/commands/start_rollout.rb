param! "host", "a host to rollout the stack on"
param! "stack", "the stack name"

accept_extra_params

execute do |params|
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.load_plugin("machine" => "localhost", "plugin_file_name" => "/root/virtualop_plugins/plugin_dev/plugin_dev.plugin")
  
  params["machine"] = params["host"]
  params.delete("host")
  @op.trigger_stack_rollout(params)
end