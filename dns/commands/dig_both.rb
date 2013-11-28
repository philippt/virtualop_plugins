description "performs both a forward and reverse lookup for a given IP address or hostname (wraps 'dig')"

param :machine, "the machine to execute 'dig' on", :mandatory => false, :default_value => 'localhost'
param! "query", "the thing to query for - can be either an IP address or an hostname", :is_default_param => true
param "name_server", "the nameserver that should be queried"
param 'dont_fail', 'if set to true, will not raise an exception if the forward lookup returns no results', :default_value => false

mark_as_read_only

add_columns [ "direction", "hostname", "ip" ]

on_machine do |machine, params|
  result = []

  options = {
    "query" => params["query"]
  }
  options['name_server'] = params['name_server'] if params.has_key?('name_server')
  result += machine.dig(options)
      
  $logger.debug "first result : #{result.last}"
  if result.size() > 0
    second_query = result.last["direction"] == "forward" ? result.last["ip"] : result.last["hostname"]
    $logger.debug "now querying for #{second_query}"
    options = {
      "query" => second_query 
    }
    options['name_server'] = params['name_server'] if params.has_key?('name_server')
    result += machine.dig(options)
  else
    unless params['dont_fail']
      raise "got no forward lookup results for '#{params["query"]}'"
    end 
  end

  result
end