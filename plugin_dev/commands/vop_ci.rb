description "tests if a vop machine can setup new machines"

github_params

param! "host", "a host to run CI on"
param "default_user", "default SSH user"
param "default_password", "default SSH password"
param "marvin_email", "if specified, an account with the name 'marvin' and this email address is created. also see marvin_password"
param "marvin_password", "the password for the marvin user"
param "target_host", "a production host onto which the new version is rolled out after successful tests"
param 'data_repo'
param 'release_version'

accept_extra_params 

execute do |params|
  begin
    if params.has_key?('marvin_email') && params.has_key?('marvin_password')
      @op.with_machine('localhost') do |machine|
        user_data = {
          "login" => "marvin"
        }.merge_from(params, :marvin_email => :email, :marvin_password => :password)
        escaped_user_data = user_data.pretty_inspect()
        machine.rvm_ssh("cd /home/marvin/virtualop_webapp && rails runner 'puts $op.add_rails_user(#{escaped_user_data})'")
      end
    end
  rescue => detail
    $logger.error("could not create marvin user : #{detail.message}")
  end
  
  #@op.find_vms
  
  @op.load_dev_plugin
  
  @op.trigger_stack_rollout("machine" => params["host"], "stack" => "minimal_platform", "extra_params" => {
    "prefix" => "ci_", "domain" => "ci.virtualop.org",
    "default_user" => params["default_user"],
    "default_password" => params["default_password"] 
  })
  
  if params['release_version']
    @op.tag_as({
      'machine' => 'localhost', 
      'keypair' => 'ci_vop',
      'tag' => params['release_version']
    }.merge_from(params, :github_token))
    
    # TODO extract maybe?
    if params['target_host']
      p = {
        'host' => params['target_host'],
        'stack' => 'vop'
      }.merge_from(params, :extra_params)
      p['extra_params'] ||= {}
      p['extra_params'].merge!(
        'keypair' => 'ci_vop',
        'environment' => 'production',
        'service_root' => '/home/marvin/virtualop_webapp',
        'git_branch' => params['release_version']
      )
      p['extra_params'].merge!(
        "default_user" => params["default_user"],
        "default_password" => params["default_password"]
      ) if params['default_user'] 
      p['extra_params'].merge!('data_repo' => params['data_repo']) if params['data_repo']
      @op.start_rollout(p)
    end
  else
    @op.tag_as({
      'machine' => 'localhost', 
      'keypair' => 'ci_vop',
      'comment' => "passed CI #{Time.now.strftime("%Y%m%d")}"
    }.merge_from(params, :github_token))
  end
  
end