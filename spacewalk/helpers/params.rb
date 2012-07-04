def param_spacewalk_host(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_spacewalks.values
    },
    :autofill_context_key => 'spacewalk_host'    
  })
  RHCP::CommandParam.new("spacewalk_host", "the spacewalk server to work with", options)
end  

def param_spacewalk_system_group(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_system_groups.map do |spacewalk|
        spacewalk["name"]
      end
    }
  })
  RHCP::CommandParam.new("spacewalk_system_group", "a system group defined in spacewalk to work with", options)
end

def param_activation_key(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_activation_keys.map do |ak|
        ak["key"]
      end
    }
  })
  RHCP::CommandParam.new("activation_key", "the activation key to work with", options)
end

def param_config_channel(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_config_channels.map do |cc|
        cc["name"]
      end
    }
  })
  RHCP::CommandParam.new("config_channel", "the config channel to work with", options)
end

def param_system_group(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_system_groups.map { |x| x["name"] }
    }
  })
  RHCP::CommandParam.new("system_group", "the system group to work with", options)
end