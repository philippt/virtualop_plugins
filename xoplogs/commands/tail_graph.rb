description "uses tail to read the last x lines of a log file and calls xoplogs to aggregate the data"

param :machine
param! "path", "path to the logfile (see find_logs)"

on_machine do |machine, params|
  
  params["lines"] = machine.tail("lines" => 1000, "file_name" => params["path"])
  
  @op.graph_lines(params)
  # log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  # raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  # raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
#   
  # tempfile = "#{@op.home("machine" => "localhost")}/tmp/tail_graph.tmp"
  # begin
    # @op.write_file("machine" => "localhost", "target_filename" => tempfile, "content" => lines)
    # JSON.parse(@op.http_form_upload(
      # "machine" => "localhost",
      # "target_url" => xoplogs_url + '/import_log/parse_and_aggregate', 
      # "file_name" => tempfile,
      # "param_name" => "pic",
      # "extra_content" => "parser=#{log_file["parser"]}"
    # ))
  # ensure
    # @op.rm("machine" => "localhost", "file_name" => tempfile)
  # end
end  
