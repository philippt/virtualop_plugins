description "tests if a vop machine can setup new machines"

param :machine, "a host to work with"

on_machine do |machine, params|
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
  
  host_name = params["machine"]
  
  @op.configure_my_sql("mysql_user" => "root", "mysql_password" => "the_password")
  
  @op.configure_nagios_config_generator("nagios_machine_name" => "ci_nagios.#{host_name}", "default_services" => ["ssh"])
  @op.configure_nagios_status("nagios_bin_url" => "http://nagios.ci.virtualop.org/nagios/cgi-bin", "nagios_user" => "nagiosadmin", "nagios_password" => "the_password")
  #@op.generate_nagios_config("machine" => "vop_ci_website.zapata.virtualop")
  
  @op.configure_xoplogs("xoplogs_machine" => "ci_xoplogs.#{host_name}", "auto_import_machine_groups" => [ host_name ])
  
  @op.configure_data_repo
  @op.add_data_repo("alias" => "ci", "machine" => "ci_datarepo.#{host_name}", "url" => "http://datarepo.ci.virtualop.org")
  
  @op.with_machine('localhost') do |localhost|
    localhost.install_service_from_working_copy("working_copy" => "virtualop", "service" => "import_logs")
    %w|rails_dev_server executor message_processor|.each do |service|
      localhost.restart_service("service" => service)
    end
  end
  
  @op.configure_stacks
  @op.load_plugin("machine" => "localhost", "plugin_file_name" => "/root/virtualop_plugins/plugin_dev/plugin_dev.plugin")
  @op.generate_jenkins_jobs_for_stack("machine" => host_name, "stack" => "minimal_platform", "prefix" => "ci_", "extra_params" => { "domain" => "ci.virtualop.org" })
  
  
  #@op.create_jenkins_job("job_name" => "nagios", "command_string" => "kaboom_vm machine=vop_ci_nagios.zapata.virtualop canned_service=nagios/nagios domain=nagios.ci.virtualop.org")
  #@op.create_jenkins_job("job_name" => "xoplogs", "command_string" => "kaboom_vm machine=vop_ci_xoplogs.zapata.virtualop github_project=philippt/xoplogs domain=xoplogs.ci.virtualop.org")
  
  @op.trigger_build("jenkins_job" => "ci_nagios.#{host_name}")
  #@op.trigger_build("jenkins_job" => "xoplogs")
end
