description "setup a virtualop and a proxy so that a web interface is reachable"

param! "domain", :description => "the domain for the virtualop instance"
param! "hetzner_account", :description => "hetzner accounts to upload to the new vop instance", :allows_multiple_values => true
param! "keypair", :description => "ssh keypair that should be uploaded to the new vop"
param "clone", :description => "if set to true, the vop rolling out the stack will make a backup of itself into it's data repo and use this for setting up the new vop"
param "github_token"

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
  
  @op.with_machine(stacked["vop"].first["full_name"]) do |vop|
    vop.as_user('marvin') do |marvin|
      marvin.upload_stored_keypair("keypair" => params["keypair"])
      marvin.transfer_keypair("keypair" => params["keypair"])
      
      params["hetzner_account"].each do |hetzner_account|
        marvin.upload_hetzner_account("hetzner_account" => hetzner_account)
      end      
      
      marvin.vop_call("force" => "true", "command" => "find_vms", "logging" => "true")
      
      marvin.upload_data_repo("target_alias" => "old_data_repo")
      
      if params["clone"]
        identity = @op.whoareyou.split('@').last
        @op.with_machine(identity) do |me|
          me.backup_data()
        end
        marvin.vop_call("logging" => "true", "command" => "restore_self")
      end
      
      marvin.vop_call("force" => "true", "logging" => "true", "command" => "start_rollout", 
        "host" => params["machine"], "stack" => "minimal_platform", "extra_params" => params["extra_params"] 
      )
    end
  end
end