description "returns the data for graphing access logs for the selected service"

param :machine
param :service, "the service to work with", :mandatory => false

param! "line", "the 'line' of data that should be retrieved", 
  :lookup_method => lambda { @op.list_data_lines },
  :allows_multiple_values => true

param "interval_hours", "the number of hours that should be displayed (counting backwards from now)", 
  :default_value => 2

mark_as_read_only
# TODO expires => 15.minutes would be nice here

execute do |params|
  @op.with_machine(config_string('xoplogs_machine')) do |xoplogs|
    url = 'http://' + xoplogs.service_details("service" => "xoplogs")["domain"].first.first # TODO we know that one
    url += '/aggregated/get_data'
    url += "?hosts\\[\\]=#{params["machine"]}"
    url += "&services\\[\\]=#{params["service"]}" if params.has_key?("service")
    url += "&line=#{params["line"].join(',')}"
    url += "&interval_hours=#{params["interval_hours"]}"
    JSON.parse(@op.http_get("url" => url))
  end
end
