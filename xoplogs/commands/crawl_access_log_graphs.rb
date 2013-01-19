param :machine
param :service, "the service to work with", :mandatory => false

include_for_crawling

on_machine do |machine, params|
  next unless @op.list_services_with_access_logs.select { |x| x["host_name"] == machine.name }.size > 0
  
  @op.list_intervals.each do |i|
    @op.list_data_lines.each do |line|
      next if line == "count_total"
      machine.access_log_graph(params.merge("interval_hours" => i, "line" => line))
    end
  end  
end  
