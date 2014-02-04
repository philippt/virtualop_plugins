description "lists all available activation keys"

param :spacewalk_host

mark_as_read_only()

add_columns [ "name", "stack_name", "environment", "functionality", "base_channel_label" ]

#param "stack_filter"

execute_on_spacewalk do |server, session, params|
  result = []
  keys = server.call('activationkey.listActivationKeys', session)
  keys.each do |key|
    key_name = key["key"]

    decoded = decode_activation_key_name(key_name)

    if decoded != nil
      if params.has_key?('stack_name')
        next unless decoded["stack_name"] == params['stack_name']
      end

      result << key
      result.last["name"] = result.last["key"]

      decoded.each do |k,v|
        result.last[k] = v
      end
    end
  end      
  result
end
