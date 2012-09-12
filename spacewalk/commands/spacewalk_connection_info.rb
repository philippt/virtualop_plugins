description "returns the spacewalk hostname and IP currently used"

param :spacewalk_host

mark_as_read_only

display_type :hash

execute do |params|
  connection = @op.get_spacewalk_connection("spacewalk_host" => params['spacewalk_host'])
  {
    'hostname' => connection.hostname,
    'ip' => @op.with_machine('localhost') { |x| x.dig("query" => connection.hostname).first["ip"] } 
  }
end  
