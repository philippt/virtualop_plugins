description "returns a list fo all configuration channels to which the specified activation key is subscribed"

param :spacewalk_host
param :activation_key

mark_as_read_only

add_columns [ "id", "label", "name", "description" ]

execute_on_spacewalk do |server, session, params|
  result = server.call('activationkey.listConfigChannels', session, params["activation_key"]).each do |config_channel|
    config_channel["organization"] = config_channel["orgId"]
    
    config_channel["type_id"] = config_channel["configChannelType"]["id"]
    config_channel["type_label"] = config_channel["configChannelType"]["label"]
    config_channel["type_name"] = config_channel["configChannelType"]["name"]
    config_channel["type_priority"] = config_channel["configChannelType"]["priority"]
  end
end  