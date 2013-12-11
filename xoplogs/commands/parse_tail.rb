description "uses tail to read the last x lines of a log file and calls xoplogs to parse the data"

param :machine
param! "path", "path to the logfile (see find_logs)"
param 'count', 'number of lines to parse', :default_value => 1000

on_machine do |machine, params|
  
  params["lines"] = machine.tail("lines" => params['count'], "file_name" => params["path"])
  
  params.delete('count')
  
  @op.parse_lines(params)
end  
