description "uses tail to read the last x lines of a log file and calls xoplogs to aggregate the data"

param :machine
param! "path", "path to the logfile (see find_logs)"
param 'stats_only'

on_machine do |machine, params|
  
  params["lines"] = machine.tail("lines" => 1000, "file_name" => params["path"])
  
  @op.graph_lines(params)
end  
