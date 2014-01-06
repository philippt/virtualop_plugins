param :machine
param! "path", "path to the logfile (see find_logs)"
param 'interval', '', :lookup_method => lambda { %w|minute hour day week| }, :default_value => 'hour'
param 'count', 'number of lines to parse', :default_value => 1000

display_type :hash

on_machine do |machine, params|
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  
  parser = @op.list_parsers.select { |x| x['name'] == log_file['parser'] }.first
  
  parsed = @op.parsed_tail(params)
  @op.aggregate_logdata('data' => parsed, 'log_type' => parser['type'], 'interval' => params['interval'])
end