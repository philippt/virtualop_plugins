description "takes a part of a logfile, checks for a parser to use in the service descriptor, and calls xoplogs to parse and aggregate for a graph"

param :machine
param! "path"
param! "lines"
param "for_flot"
param "tz_offset", "timezone offset (from UTC) to use for preparing the graph data"
param "interval", "if selected, only the part of the logfile in the interval is displayed", :lookup_method => lambda { %w|minute hour day week| }
param "count", "selects how many +interval+s should be displayed", :default_value => 1
param "stats_only" 

on_machine do |machine, params|
  lines = params["lines"]
  
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  
  uri = URI.parse(xoplogs_url + '/import_log/parse_and_aggregate')
  post_data = {
    "parser" => log_file["parser"], 
    "lines" => lines
  }
  post_data["type"] = log_file["format"] if log_file["format"]
  post_data.merge_from params, :interval, :count
  response = Net::HTTP.post_form(uri, post_data)  
  
  puts "gonna parse JSON"
  json = JSON.parse(response.body)
  json['raw'] = lines
  puts "json stats"
  pp json['stats']
  
  parsed = json['parsed']
  if parsed.size > 0
    first = Time.parse(parsed.first['log_ts'])
    last = Time.parse(parsed.last['log_ts'])
    puts "data range: #{first} to #{last}"
  end
  
  result = nil
  if params["stats_only"]
    result = json['stats']
  else
    if params["for_flot"] == 'true' && params.has_key?("tz_offset")
      json['stats'] = access_log_graph_flot(json['stats'], params["tz_offset"])
    end
    result = json
  end
  
  result
end  

