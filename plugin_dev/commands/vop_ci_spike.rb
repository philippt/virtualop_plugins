description "tests if a vop machine can setup new machines"

github_params

param! "host", "a host to run CI on"
param "default_user", "default SSH user"
param "default_password", "default SSH password"
param "marvin_email", "if specified, an account with the name 'marvin' and this email address is created. also see marvin_password"
param "marvin_password", "the password for the marvin user"
param "target_host", "a production host onto which the new version is rolled out after successful tests"
#param "target_domain", "ugly workaround because we need to specify alpha/beta. necessary for target_host to work"

accept_extra_params 

execute do |params|
  #@op.tag_as_stable({'machine' => 'localhost', 'keypair' => 'ci_vop'}.merge_from params, :github_token)
  @op.tag_as_stable({'machine' => 'localhost', 'keypair' => 'ci_vop'}.merge_from(params, :github_token))
end