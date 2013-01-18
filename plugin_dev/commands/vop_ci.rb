description "tests if a vop machine can setup new machines"

param :machine, "a host to work with"

on_machine do |machine, params|
  host_name = params["machine"]
  
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.load_plugin("machine" => "localhost", "plugin_file_name" => "/root/virtualop_plugins/plugin_dev/plugin_dev.plugin")
  @op.generate_jenkins_jobs_for_stack("machine" => host_name, "stack" => "minimal_platform", "extra_params" => { "domain" => "ci.virtualop.org", "prefix" => "ci_" })
  
  @op.minimal_platform_stackinstall("domain" => "ci.virtualop.org", "machine" => host_name, "extra_params" => { "prefix" => "ci_" })
  
  @op.trigger_build("jenkins_job" => "ci_nagios.#{host_name}")
  @op.trigger_build("jenkins_job" => "ci_xoplogs.#{host_name}")
end
