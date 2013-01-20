param :machine
param! "host", "a host to run CI on"

on_machine do |machine, params|
  #machine.vop_call("logging" => "true", "command" => "vop_ci machine=#{params["host"]}")
  #@op.configure_stacks unless @op.list_plugins.include? "stacks"
  machine.vop_call("logging" => "true", "command" => "trigger_stack_rollout machine=#{params["host"]} stack=minimal_platform prefix=ci_ domain=ci.virtualop.org")
end  
