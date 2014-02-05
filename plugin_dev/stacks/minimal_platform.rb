description "minimal set of infrastructure for running a web platform"

param! "domain"
param "target_domain", :description => "alternative domain that should be enabled during post_rollout"
param "target_github_data", :description => "github application id and secret, separated by a slash. used for oauth integration"
param "datarepo_init_url", :description => "http URL to initialize the datarepo from"
param "default_user", :description => "default SSH user"
param "default_password", :description => "default SSH password"

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
  m.param('datarepo_init_url', params['datarepo_init_url']) if params.has_key?('datarepo_init_url')
  
  datarepo_alias = 
    (params.has_key?("extra_params") && params["extra_params"] != nil && params["extra_params"].has_key?("prefix")) ?
    params["extra_params"]["prefix"][0..-1] : 
    m.full_name
  if datarepo_alias && datarepo_alias != ''
    m.param('alias', datarepo_alias)
  end 
  m.disk 100
end
 
stack :vop_website do |m, params|
  m.github 'philippt/virtualop_website'
  m.domain params["domain"]
  m.param('vop_url', "http://vop.#{params["domain"]}")
end

# stack :powerdns do |m, params|
  # m.canned_service :powerdns
# end
# 
stack :ldap do |m, params|
  m.canned_service :centos_ldap
  m.domain params["domain"]
end

stack :selenium do |m, params|
  m.canned_service :selenium
end  
 
#stack :owncloud do |m, params|
#  m.canned_service :owncloud_server
#  m.domain_prefix 'owncloud'
#   
  # m.param('ldap_host', "ldap.#{params["domain"]}")
  # m.param('ldap_domain', params["domain"])
  # m.param('bind_user', 'cn=manager')
  # m.param('bind_password', 'the_password')
#end

# stack :openfire do |m, params|
  # m.canned_service :openfire
  # m.domain_prefix 'openfire'
# end
 
on_install do |stacked, params|
  @op.comment("foo minimal_platform $29.00 foo")
  
  s = ""
  stacked.keys.each do |stack_name|
    s += "\t#{stack_name} : #{stacked[stack_name].first["full_name"]}\t#{stacked[stack_name].first["domain"]}\n"
  end
  @op.comment "stacks:\n#{s}"
  
  host_name = params["machine"]
  @op.comment "host : #{host_name}"
  
  if params.has_key?("default_user")
    @op.configure_default_passwords({}.merge_from(params, :default_user, :default_password))
  end
  # TODO hardcoded credentials
  @op.configure_my_sql("mysql_user" => "root", "mysql_password" => "the_password")
  
  old_repos = @op.list_data_repos.select { |x| x["alias"] == "old_data_repo" }
  @op.comment("found #{old_repos.size} old repos")
  if old_repos.size > 0
    old_repo = old_repos.first
    @op.restore_self
    # identity = @op.whoareyou.split('@').last
    # @op.with_machine(identity) do |me|
      # me.restore_data()
      # @op.configure_machines("identity" => identity)
#       
      # vop_webapp_path = me.service_details("service" => "virtualop_webapp/virtualop_webapp")["service_root"]
      # me.rvm_ssh("cd #{vop_webapp_path} && rake db:migrate")
    # end
    
    # TODO delete old_data_repo after populating the new one?
  end

  @op.configure_nagios_config_generator("nagios_machine_name" => stacked["nagios"].first["full_name"], "default_services" => ["ssh"])
  @op.configure_nagios_status("nagios_bin_url" => "http://#{stacked["nagios"].first["domain"]}/nagios/cgi-bin", "nagios_user" => "nagiosadmin", "nagios_password" => "the_password")
  
  @op.configure_xoplogs("xoplogs_machine" => stacked["xoplogs"].first["full_name"], "auto_import_machine_groups" => [ host_name ])
  
  @op.with_machine(@op.whoareyou("name_only" => "true")) do |i|
    i.install_service_from_working_copy("working_copy" => "virtualop", "service" => "import_logs")    
    [ 'virtualop_webapp/thin', 'virtualop/launcher', 'virtualop/message_processor' ].each do |service|
      i.restart_service("service" => service)
    end
  end
end

post_rollout do |stacked, params|
  @op.comment "post rollout. successful: #{params["result"][:success].size}, failed: #{params["result"][:failure].size}"
  
  pp params
  
  failure = params["result"][:failure]
  raise "some stacks could not be rolled out: #{failure.map { |x| x["name"] }}" unless failure.size == 0
  
  params.delete("result")
  
  if params.has_key?('extra_params')
    params.merge! params['extra_params']
  end
  pp params
  
  if params.has_key?("target_domain")
    target_domain = params["target_domain"]
    if target_domain.is_a? Array
      target_domain = target_domain.first
    end
    new_vop_domain = "vop.#{target_domain}"
    @op.with_machine(@op.whoareyou.split('@').last) do |vop|
      vop.change_runlevel("runlevel" => "maintenance")
      extra_params = {
        "domain" => new_vop_domain
      }
      if params.has_key?("target_github_data")
        github_data = params["target_github_data"]
        if github_data.is_a? Array
          github_data = github_data.first
        end 
        extra_params["github_application_id"], extra_params["github_secret"] =
          github_data.split('/')
      end
      # TODO dropbox
      vop.install_service_from_working_copy("working_copy" => "virtualop_webapp", "service" => "virtualop_webapp", "extra_params" => extra_params)
      vop.change_runlevel("runlevel" => "running")
    end
    
    @op.with_machine(stacked["vop_website"].first["full_name"]) do |vop_website|
      vop_website.change_runlevel("runlevel" => "maintenance")
      vop_website.install_service_from_working_copy("working_copy" => "virtualop_website", "service" => "virtualop_website", "extra_params" => {
        "domain" => target_domain,
        "vop_url" => "http://#{new_vop_domain}"        
      })   
      vop_website.change_runlevel("runlevel" => "running")
    end
    
    # TODO a tiny bit of testing would be helpful at this point
    
    hetzner_host = @op.list_all_hetzner_hosts.select { |x| x["server_ip"] == @op.ipaddress("machine" => params["machine"]) }.first
    if hetzner_host
      account = hetzner_host["account"]
      failover_ip = @op.list_failover_ips("hetzner_account" => account).select { |x| x["ip_lookup"] == target_domain }.first
      if failover_ip
        old_host_name = @op.list_all_hetzner_hosts.select { |x| x["server_ip"] == failover_ip["active_server_ip"] }.first["name"]
        
        @op.with_machine(params["machine"]) do |new_host|
          new_host.add_ip_address("address" => failover_ip["ip"], "device" => "eth0") unless
            new_host.list_ip_addresses.map { |x| x["address"] }.include? failover_ip["ip"]
        end
        
        @op.switch_failover_ip("hetzner_account" => account, "ip" => failover_ip["ip"], "target_ip" => hetzner_host["server_ip"])
        
        @op.with_machine(old_host_name) do |old_host|
          old_host.delete_ip_address("address" => failover_ip["ip"], "device" => "eth0")
        end
      end
    end
  end
end
