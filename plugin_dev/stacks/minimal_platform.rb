description "minimal set of infrastructure for running a web platform"

param! "domain", :description => "the domain root for the web application"
param "datarepo_init_url", "http URL to initialize the datarepo from"

stack :nagios do |m, p|
  m.canned_service :nagios
  m.domain_prefix 'nagios' 
  m.memory [ 512, 1024, 1024 ]
  m.disk 50
end
 
stack :xoplogs do |m, params|
  m.github 'philippt/xoplogs'
  m.domain_prefix 'xoplogs'
  m.memory [ 512, 1024, 2048 ]
  m.disk 100
  
  #m.post_install do |machine|
    # TODO check if this works (lots of 'machine' thingies)
  #  @op.configure_xoplogs("xoplogs_machine" => machine.name, "auto_import_machine_groups" => [ params["machine"] ])
  #end
end
 
stack :datarepo do |m, params|
  m.canned_service :datarepo
  m.domain_prefix 'datarepo'
  m.disk 100
end
 
stack :powerdns do |m, params|
  m.canned_service :powerdns
end

stack :vop_website do |m, params|
  m.github 'philippt/virtualop_website'
  m.domain params["domain"].first
end
 
on_install do |stacked, params|
  @op.comment("foo minimal_platform $29.00 foo")
  s = ""
  stacked.keys.each do |stack_name|
    s += "\t#{stack_name} : #{stacked[stack_name].first["full_name"]}\t#{stacked[stack_name].first["domain"]}\n"
  end
  @op.comment "stacks:\n#{s}"
  
  host_name = params["machine"]
  @op.comment "host : #{host_name}"
  
  @op.configure_my_sql("mysql_user" => "root", "mysql_password" => "the_password")
  
  @op.configure_nagios_config_generator("nagios_machine_name" => stacked["nagios"].first["full_name"], "default_services" => ["ssh"])
  @op.configure_nagios_status("nagios_bin_url" => "http://#{stacked["nagios"].first["domain"]}/nagios/cgi-bin", "nagios_user" => "nagiosadmin", "nagios_password" => "the_password")
  
  @op.configure_xoplogs("xoplogs_machine" => stacked["xoplogs"].first["full_name"], "auto_import_machine_groups" => [ host_name ])
  
  old_repos = @op.list_data_repos.select { |x| x["alias"] == "old_data_repo" }
  @op.comment("found #{old_repos.size} old repos")
  if old_repos.size > 0
    old_repo = old_repos.first
    #@op.with_machine(@op.whoareyou.split('@').last)
    @op.with_machine('localhost') do |localhost|
      identity = @op.whoareyou.split('@').last
      localhost.restore_data()
      @op.configure_machines("identity" => identity)
      
      vop_webapp_path = localhost.service_details("service" => "virtualop_webapp")["service_root"]
      localhost.ssh_and_check_result("command" => "cd #{vop_webapp_path} && rake db:migrate")
    end
  end
  
  #@op.configure_data_repo
  datarepo_alias = (
    (params.has_key?("extra_params") and params["extra_params"] != nil and params["extra_params"].has_key?("prefix")) ?
    params["extra_params"]["prefix"][0..-1] : 
    stacked["datarepo"].first["full_name"]
  )
  @op.add_data_repo("alias" => datarepo_alias, 
    "machine" => stacked["datarepo"].first["full_name"], 
    "url" => "http://#{stacked["datarepo"].first["domain"]}"
  )
  
  
  # TODO this should happen after the datarepo has been rolled out
  #if params.has_key?("datarepo_init_url")
  #  @op.populate_repo_from_url("machine" => stacked["datarepo"].first["full_name"], "source_url" => params["datarepo_init_url"])
  #end
  
  # TODO delete old_data_repo after populating the new one
  
  @op.with_machine('localhost') do |localhost|
    localhost.install_service_from_working_copy("working_copy" => "virtualop", "service" => "import_logs")
    %w|rails_dev_server executor message_processor|.each do |service|
      localhost.restart_service("service" => service)
    end
  end
end
