description "takes a part of a logfile, checks for a parser to use in the service descriptor, then calls xoplogs to parse"

param :machine
param! "path"
param! "lines"

on_machine do |machine, params|
  lines = params["lines"]
  
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  
  uri = URI.parse(xoplogs_url + '/import_log/parse')
  post_data = {
    "parser" => log_file["parser"], 
    "lines" => lines
  }
  post_data["type"] = log_file["format"] if log_file["format"]
  response = Net::HTTP.post_form(uri, post_data)  
  
  JSON.parse(response.body)
end  