description "stores custom info in spacewalk for the current host"

param :spacewalk_host
param :machine
param! "key", "the name of the custom info field that should be set", 
  :lookup_method => lambda { @op.list_custom_info_keys.map { |x| x["label"] } }
param! "value", "the value that should be set"

execute_on_spacewalk do |server, session, params|
  custom_values = {
    params["key"] => params["value"]
  }
  server.call('system.setCustomValues', session, @op.spacewalk_id("machine" => params["machine"]), custom_values)
  
  @op.without_cache do
    @op.get_custom_info("machine" => params["machine"])
  end
end  
