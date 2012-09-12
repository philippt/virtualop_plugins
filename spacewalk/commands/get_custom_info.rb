description "returns the custom info values defined in spacewalk for the current machine"

param :spacewalk_host
param :machine

mark_as_read_only

add_columns [ "key", "value" ]

execute_on_spacewalk do |server, session, params|
  spacewalk_id = @op.spacewalk_id("machine" => params["machine"])
  result = server.call('system.getCustomValues', session, spacewalk_id)
  
  result.map do |row|
    {
      "key" => row[0],
      "value" => row[1]
    }      
  end
end  
