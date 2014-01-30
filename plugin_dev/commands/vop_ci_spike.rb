description "tests if a vop machine can setup new machines"

github_params

param! "host", "a host to run CI on"
param "default_user", "default SSH user"
param "default_password", "default SSH password"
param "marvin_email", "if specified, an account with the name 'marvin' and this email address is created. also see marvin_password"
param "marvin_password", "the password for the marvin user"
param "target_host", "a production host onto which the new version is rolled out after successful tests"

accept_extra_params 

execute do |params|
  p = {
    'host' => params['target_host'],
    'stack' => 'vop'
  }.merge_from(params, :extra_params)
  p['extra_params'] ||= {}
  p['extra_params'].merge!(
    'keypair' => 'ci_vop',
    'environment' => 'production',
    'service_root' => '/home/marvin/virtualop_webapp',
    'git_branch' => 'stable'
  )
  @op.start_rollout(p)
  
end