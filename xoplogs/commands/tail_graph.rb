description "uses tail to read the last x lines of a log file and calls xoplogs to aggregate the data"

param :machine
param! "path", "path to the logfile (see find_logs)"

on_machine do |machine, params|
  
  details = @op.service_details("machine" => config_string('xoplogs_machine'), "service" => "xoplogs")
  xoplogs_url = 'http://' + details["domain"].first.first # TODO we know that one
  
  lines = machine.tail("lines" => 1000, "file_name" => params["path"])
  
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  
  tempfile = @op.write_tempfile("data" => lines)
  JSON.parse(@op.http_form_upload(
    "machine" => "localhost",
    "target_url" => xoplogs_url + '/import_log/parse_and_aggregate', 
    "file_name" => tempfile.path,
    "param_name" => "pic",
    "extra_content" => "parser=#{log_file["parser"]}"
  ))
end  
