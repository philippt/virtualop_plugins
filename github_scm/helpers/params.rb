def github_params
  param "github_user", "the github user to use"
  param "github_password", "the password that should be used (http basic auth)"
  param "github_token", "the OAuth token to be used "
end  

def param_github_project(options = {})
  merge_options_with_defaults(options, {
  })
  RHCP::CommandParam.new("github_project", "the github project to install (e.g. philippt/virtualop)", options)
end