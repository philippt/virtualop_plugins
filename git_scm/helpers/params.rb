def param_git_branch(options = {})
  merge_options_with_defaults(options, {
  })
  RHCP::CommandParam.new("git_branch", "the branch that should be default after checkout (defaults to HEAD/master)", options)
end

def param_git_tag(options = {})
  merge_options_with_defaults(options, {
    
  })
  RHCP::CommandParam.new("git_tag", "a git tag that should be used for deploying", options)
end

def param_remote(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { |request|
      @op.list_remotes("machine" => request.get_param_value("machine"), "working_copy" => request.get_param_value("working_copy")).map { |x| x["name"] } 
    }
  })
  RHCP::CommandParam.new("remote", "the name of the remote (repository configuration)", options) 
end