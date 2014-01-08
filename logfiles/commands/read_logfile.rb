param :machine
param! 'path'
param 'line_count', '', :default_value => 10
param! 'interval', '', :lookup_method => lambda { %w|minute hour day week| }, :default_value => 'hour'
param 'count', 'amount of intervals to display', :default_value => 1
param "for_flot"
param "tz_offset", "timezone offset (from UTC) to use for preparing the graph data"
param 'wanted', 'list what should be returned', :allows_multiple_values => true, :lookup_method => lambda { %w|raw parsed stats| }, :default_value => ['stats']

on_machine do |machine, params|
  result = {}
  
  timing = {}
  total_start = Time.now
  
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  parser = @op.list_parsers.select { |x| x['name'] == log_file['parser'] }.first
  
  machine_detail = machine.machine_detail
  tail_params = {
    "lines" => params['line_count'], "file_name" => params["path"]
  }
  start = Time.now  
  raw = if machine_detail && machine_detail['os'] && machine_detail['os'] == 'windows'
    machine.win_tail(tail_params)
  else
    machine.tail(tail_params)
  end
  timing[:read] = Time.now - start
  result['raw'] = raw if params['wanted'].include?('raw')
  
  lines = raw.split("\n")
  start = Time.now
  parsed = @op.parse_logdata('parser' => log_file['parser'], 'data' => lines, 'tz_offset' => params['tz_offset'].to_i, 'extra_params' => { 'tz_offset' => params["tz_offset"].to_i })
  timing[:parsed] = Time.now - start
  result['parsed'] = parsed  if params['wanted'].include?('parsed')
  
  start = Time.now
  aggregated = @op.aggregate_logdata('data' => parsed, 'log_type' => parser['type'], 'interval' => params['interval'])
  timing[:aggregate] = Time.now - start
  #puts "aggregated"
  #pp aggregated
  start = Time.now
  stats = @op.graph_logdata({'data' => aggregated, 'log_type' => parser['type']}.merge_from(params, :interval, :count))
  timing[:graph] = Time.now - start
  #puts "graph"
  #pp graph
  
  
  if params["for_flot"] == 'true' && params.has_key?("tz_offset")
    stats = flot_graph(stats, params["tz_offset"].to_i)
  end
  
  result['stats'] = stats if params['wanted'].include?('stats')
  
  timing[:total] = Time.now - total_start
  pp timing
  
  result
end
