description "returns the data for graphing access logs for the selected service"

param :machine
param :service, "the service to work with", :mandatory => false

param! "line", "the 'line' of data that should be retrieved", :lookup_method => lambda { %w|count_success count_errors count_total response_time_ms| }

execute do |params|
  @op.with_machine(config_string('xoplogs_machine')) do |xoplogs|
    url = 'http://' + xoplogs.service_details("service" => "xoplogs")["domain"].first.first # TODO we know that one
    url += '/aggregated/get_data'
    url += "?hosts\\[\\]=#{params["machine"]}"
    url += "&services\\[\\]=#{params["service"]}" if params.has_key?("service")
    url += "&line=#{params["line"]}"
    url += "&interval_hours=6"
    @op.http_get("url" => url)
  end
end
