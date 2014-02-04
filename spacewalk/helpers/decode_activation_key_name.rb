# TODO kaboom here, please.

def decode_activation_key_name(key)
  stack_name = nil
  environment = nil
  functionality = nil
  name = nil

  # new style names : <env>_<functionality>_<stack>
  new_convention_match = /(#{env_regex}_(.+)_([^\d]+))$/.match(key)
  if new_convention_match
    name = new_convention_match.captures[0]
    environment = new_convention_match.captures[1]
    functionality = new_convention_match.captures[2]
    stack_name = new_convention_match.captures[3]
    $logger.debug "identified stack '#{stack_name}' through activation key #{key}"
  else
    # old style names : <env>_<something>_<optional version>
    the_match = /(#{env_regex}_(.+?)(_\d+(?:_|\.)\d+)?)$/.match(key)
    if the_match
      name = the_match.captures[0]
      environment = the_match.captures[1]
      stack_name = the_match.captures[2]
      prefix_match = /bm_(.+)/.match(stack_name)
      if prefix_match
        stack_name = prefix_match.captures[0]
        $logger.warn "stripping old-style prefix 'bm_'"
      end
      # TODO old-style convention
      $logger.debug "old-style convention: identified stack '#{stack_name}' through activation key #{key}"
    end
  end

  if name != nil
    {
      "name" => name,
      "stack_name" => stack_name,
      "environment" => environment,
      "functionality" => functionality
    }
  else
    nil
  end
end

def list_environments
#    @op.list_environments.map do |env|
#      env["short_name"]
#    end
    # TODO kill this
  %w|pro stg inf bof dev int lab|    
end

def env_regex
  '(' + list_environments.join('|') + ')'
end