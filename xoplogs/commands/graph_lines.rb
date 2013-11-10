description "takes a part of a logfile, checks for a parser to use in the service descriptor, and calls xoplogs to parse and aggregate for a graph"

param :machine
param! "path"
param! "lines"
param "for_flot"
param "tz_offset", "timezone offset (from UTC) to use for preparing the graph data"

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
  puts "posting to #{uri} : #{post_data}"
  response = Net::HTTP.post_form(uri, post_data)  
  
  result = JSON.parse(response.body)
  
  if params["for_flot"] == 'true' && params.has_key?("tz_offset")
    result = access_log_graph_flot(result, params["tz_offset"])
  end
  
  result
end  

