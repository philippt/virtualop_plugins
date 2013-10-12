description "tests if a vop machine can setup new machines"

param! "host", "a host to run CI on"
param "default_user", "default SSH user"
param "default_password", "default SSH password"

execute do |params|
  @op.find_vms
  
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.with_machine("localhost") do |localhost|
    localhost.load_plugin("plugin_file_name" => "#{localhost.home}/virtualop_plugins/plugin_dev/plugin_dev.plugin")    
  end
  
  @op.add_known_machine("name" => "localhost", "ssh_user" => "marvin", "type" => "vm", "ssh_host" => "localhost")
  if params.has_key?("default_user")
    @op.configure_default_passwords({}.merge_from(params, :default_user, :default_password))
  end
  
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org" 
  })  
end