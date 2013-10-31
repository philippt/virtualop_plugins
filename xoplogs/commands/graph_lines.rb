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
  
  result = nil
  
  # TODO should be more original in naming
  tempfile = "#{@op.home("machine" => "localhost")}/tmp/tail_graph.tmp"
  begin
    @op.write_file("machine" => "localhost", "target_filename" => tempfile, "content" => lines)
    result = JSON.parse(@op.http_form_upload(
      "machine" => "localhost",
      "target_url" => xoplogs_url + '/import_log/parse_and_aggregate', 
      "file_name" => tempfile,
      "param_name" => "pic",
      "extra_content" => "parser=#{log_file["parser"]}"
    ))
  ensure
    @op.rm("machine" => "localhost", "file_name" => tempfile)
  end
  
  if params["for_flot"] == 'true' && params.has_key?("tz_offset")
    result = access_log_graph_flot(result, params["tz_offset"])
  end
  
  result
end  

