param :machine
param :service, "the service to work with", :mandatory => false

include_for_crawling

on_machine do |machine, params|
  next unless @op.list_services_with_access_logs.select { |x| x["host_name"] == machine.name }.size > 0
  
  @op.list_intervals.each do |i|
    machine.access_log_graph(params.merge("interval_hours" => i, "line" => %w|count_success count_errors response_time_ms|))
  end  
end  
