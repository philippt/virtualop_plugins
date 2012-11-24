description "tests if a vop machine can setup new machines"

execute do |params|
  @op.find_vms
  
  
  # @op.kaboom_vm(
    # "machine" => "vop_ci_website.zapata.virtualop",
    # "github_project" => "philippt/virtualop_website",
    # "extra_params" => {
      # "domain" => "website.ci.virtualop.org"
    # }
  # )
#   
  # @op.kaboom_vm(
    # "machine" => "vop_ci_vop.zapata.virtualop",
    # "github_project" => "virtualop/virtualop_webapp",
    # "git_branch" => "rails3",
    # "extra_params" => {
      # "domain" => "vop.ci.virtualop.org"
    # }
  # )
  
  # @op.kaboom_vm(
    # "machine" => "vop_ci_xoplogs.zapata.virtualop",
    # "github_project" => "philippt/xoplogs",
    # "extra_params" => {
      # "domain" => "xoplogs.ci.virtualop.org"
    # }
  # )
#   
  # @op.kaboom_vm(
    # "machine" => "vop_ci_nagios.zapata.virtualop",
    # "canned_service" => "nagios/nagios",
    # "extra_params" => {
      # "domain" => "nagios.ci.virtualop.org"
    # }
  # )
  
  @op.configure_my_sql("mysql_user" => "root", "mysql_password" => "the_password")
  
  @op.configure_nagios_config_generator("nagios_machine_name" => "vop_ci_nagios.zapata.virtualop", "default_services" => ["ssh"])
  @op.configure_nagios_status("nagios_bin_url" => "http://nagios.ci.virtualop.org/nagios/cgi-bin", "nagios_user" => "nagiosadmin", "nagios_password" => "the_password")
  @op.generate_nagios_config("machine" => "vop_ci_website.zapata.virtualop")
  
  @op.configure_xoplogs("xoplogs_machine" => "vop_ci_xoplogs.zapata.virtualop", "auto_import_machine_groups" => [ 'zapata.virtualop' ])
  
  # TODO restart application services
  @op.with_machine('localhost') do |localhost|
    localhost.change_runlevel("runlevel" => "maintenance")
    localhost.change_runlevel("runlevel" => "running")
  end
  
  @op.create_jenkins_job("job_name" => "nagios ci", "command_string" => "kaboom_vm machine=vop_ci_nagios.zapata.virtualop canned_service=nagios/nagios domain=nagios.ci.virtualop.org")
  @op.create_jenkins_job("job_name" => "xoplogs ci", "command_string" => "kaboom_vm machine=vop_ci_xoplogs.zapata.virtualop github_project=philippt/xoplogs domain=xoplogs.ci.virtualop.org")
end
