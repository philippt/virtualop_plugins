description "tests if a vop machine can setup new machines"

execute do |params|
  @op.find_vms
  
  @op.kaboom_vm(
    "machine" => "vop_ci_website.zapata.virtualop",
    "github_project" => "philippt/virtualop_website",
    "extra_params" => {
      "domain" => "website.ci.virtualop.org"
    }
  )
  
  @op.kaboom_vm(
    "machine" => "vop_ci_vop.zapata.virtualop",
    "github_project" => "virtualop/virtualop_webapp",
    "git_branch" => "rails3",
    "extra_params" => {
      "domain" => "vop.ci.virtualop.org"
    }
  )
  
  @op.kaboom_vm(
    "machine" => "vop_ci_nagios.zapata.virtualop",
    "canned_service" => "nagios/nagios",
    "extra_params" => {
      "domain" => "nagios.ci.virtualop.org"
    }
  )
end
