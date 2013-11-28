execute do |params|
  result = nil
  
  details = @op.service_details('machine' => config_string('xoplogs_machine'), 'service' => 'xoplogs/xoplogs')
  
  result = details["domain"]
  
  if result.is_a? Array
    result = result.first
  end
  
  "http://#{result}"
end
