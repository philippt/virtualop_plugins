description "tests if a vop machine can setup new machines"

param :machine

on_machine do |machine, params|
  machine.vop_call("command" => "find_vms")
  machine.vop_call("command" => "kaboom_vm machine=vop_ci_website.zapata.virtualop github_project=philippt/virtualop_website domain=website.ci.virtualop.org")
  machine.vop_call("command" => "kaboom_vm machine=vop_ci_vop.zapata.virtualop github_project=philippt/virtualop_webapp git_branch=rails3 domain=vop.ci.virtualop.org")
end
