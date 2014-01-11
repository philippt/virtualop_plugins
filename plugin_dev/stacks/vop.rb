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

  params['vop_machine'] = stacked["vop"].first["full_name"]   
  @op.post_rollout_vop(params)
end