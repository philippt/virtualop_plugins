description "setup a virtualop and a proxy so that a web interface is reachable"

param! "domain", :description => "the domain for the virtualop instance"
param! "hetzner_account", :description => "hetzner accounts to upload to the new vop instance", :allows_multiple_values => true
param! "keypair", :description => "ssh keypair that should be uploaded to the new vop"
param "clone", :description => "if set to true, the vop rolling out the stack will make a backup of itself into it's data repo and use this for setting up the new vop"
param "clone_from", :description => "name of a machine to clone the vop data from"
param "github_token"
param "target_domain", :description => "alternative domain that should be enabled during post_rollout"
param "target_github_data", :description => "github application id and secret, separated by a slash. used for oauth integration"

stack :vop do |m, p|
  m.github 'virtualop/virtualop_webapp', :branch => 'stable'
  m.domain_prefix 'vop'
  m.memory [ 512, 2048, 4096 ]
  m.disk 50
  m.param('service_root', '/home/marvin/virtualop_webapp')
  m.param('github_token', p['github_token']) if p.has_key?('github_token')
end

on_install do |stacked, params|
  @op.comment("installing vop stack")
  
  s = ""
  stacked.keys.each do |stack_name|
    s += "\t#{stack_name} : #{stacked[stack_name].first["full_name"]}\t#{stacked[stack_name].first["domain"]}\n"
  end
  @op.comment "stacks:\n#{s}"
  
  host_name = params["machine"]
  @op.comment "host : #{host_name}"
end  

post_rollout do |stacked, params|
  @op.comment "post vop rollout. successful: #{params["result"][:success].size}, failed: #{params["result"][:failure].size}"
  
  if params.has_key?('extra_params')
    params.merge! params['extra_params']
  end 
  
  pp params
  
  failure = params["result"][:failure]
  raise "some stacks could not be rolled out: #{failure.map { |x| x["name"] }}" unless failure.size == 0
  
  params.delete("result")
  params['extra_params'].delete('result') if params['extra_params']

  vop_machine = stacked["vop"].first["full_name"]
  @op.with_machine(vop_machine) do |vop|
    vop.as_user('marvin') do |marvin|
      @op.flush_cache # TODO #snafoo machine.home is cached as '/root'
      marvin.upload_stored_keypair("keypair" => params["keypair"])
      marvin.transfer_keypair("keypair" => params["keypair"])
      @op.comment "uploaded and transferred keypair #{params['keypair']}"
      
      params["hetzner_account"].each do |hetzner_account|
        marvin.upload_hetzner_account("hetzner_account" => hetzner_account)
        @op.comment "uploaded hetzner account #{hetzner_account}"
      end      
      
      marvin.vop_call("force" => "true", "command" => "find_vms", "logging" => "true")
      
      if params['data_repo']
        marvin.upload_data_repo('data_repo' => params['data_repo'], "target_alias" => "old_data_repo")
      end
      
      source = nil
      if params["clone"]
        source = @op.whoareyou.split('@').last
      elsif params['clone_from']
        source = params['clone_from']
      end
      
      if source
        @op.backup_data('machine' => source)
      end
      # TODO marvin.vop_call("logging" => "true", "command" => "restore_self")
      # TODO execute migrations (happens inside restore_self at the moment)
      
      p = {}
      p.merge_from params, :github_token
      p.merge! params['extra_params'] if params['extra_params']
      
      p['stack'] = 'minimal_platform'
      p['host'] = params["machine"]
      
      marvin.vop_call( 
        "command" => "start_rollout",
        "extra_params" => p,
        "force" => "true", 
        "logging" => "true" 
      )
    end
  end   
end