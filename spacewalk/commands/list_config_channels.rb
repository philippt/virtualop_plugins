description "returns a list of all config channels configured in spacewalk"

mark_as_read_only

add_columns [ "name", "description", "stack_name", "environment", "functionality" ]

param :spacewalk_host

execute_on_spacewalk do |server, session, params|
  result = []
  channels = server.call('configchannel.listGlobals', session)
  $logger.debug "found #{channels.size} config channels"

  channels.each do |channel|
    decoded = decode_activation_key_name(channel["name"])

    if decoded != nil
      if params.has_key?('stack_name')
        next unless decoded["stack_name"] == params['stack_name']
      end

      result << decoded
    else
      result << {}
    end

    result.last["name"] = channel["name"]
    result.last["description"] = channel["description"]
  end
  result
end