param :machine
param! "path", "path to the logfile (see find_logs)"
param! 'interval', '', :lookup_method => lambda { %w|minute hour day week| }, :default_value => 'hour'
param 'line_count', 'number of lines to parse', :default_value => 1000
param 'count', 'amount of intervals to display', :default_value => 1

on_machine do |machine, params|
  p = params.clone
  p['count'] = p.delete('line_count')
  buckets = @op.aggregated_tail(p)
  
  log_file, parser = logfile_detail(machine, params)
  
  @op.graph_logdata({'data' => buckets, 'log_type' => parser['type']}.merge_from params, :interval, :count)
end
