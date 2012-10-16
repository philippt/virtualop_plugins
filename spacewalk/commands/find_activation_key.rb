description "returns the activation key that has been used to setup the selected machine"

mark_as_read_only

param :spacewalk_host

param :machine

add_columns [ "name", "stack_name", "environment" ]

execute_on_spacewalk do |server, session, params|
  result = []
  system_id = @op.spacewalk_id("machine" => params["machine"])
  
  activation_keys = server.call('system.listActivationKeys', session, system_id)        
  activation_keys.each do |key|
    $logger.debug "matching against activation key #{key}"
    
    aks = @op.list_activation_keys.select { |x| x["key"] == key }
    next unless aks.size > 0
    ak = aks.first

    decoded = decode_activation_key_name(ak["name"])
    result << decoded unless decoded == nil
    result.last["key"] = key
  end
  
  if result.size > 1
    raise Exception.new("sanity check failed: found more than one activation key for one machine")
  end
  
  result
end 
