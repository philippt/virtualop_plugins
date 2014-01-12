description "uses tail to read the last x lines of a log file and parses the data"

param :machine
param! "path", "path to the logfile (see find_logs)"
param 'count', 'number of lines to parse', :default_value => 1000

display_type :list

accept_extra_params

on_machine do |machine, params|
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  
  raw = machine.tail("lines" => params['count'], "file_name" => params["path"])
  lines = raw.split("\n")
  #puts "read #{lines.size} lines from #{params['path']}@#{params['machine']}"
  #puts "first line : >>>"
  #pp lines.first
  #puts "<<<"
  #puts "parser : #{log_file['parser']}"
  p = {
    'parser' => log_file['parser'],
    'data' => lines 
  }
  p['extra_params'] = params['extra_params'] if params['extra_params']
  parsed = @op.parse_logdata(p)
  #puts "parsed #{parsed.size} of them"
  parsed
end