#global_param :environment, :lookup_method => lambda {
#      @op.list_environments
#    },
#    :allows_extra_values => true

def param_environment(options = {})
  merge_options_with_defaults(options, {
    :lookup_method => lambda {
      @op.list_environments
    },
    :allows_extra_values => true
  })
  RHCP::CommandParam.new("environment", "if specified, the environment is written into a config file so that it's available through $VOP_ENV", options) 
end
