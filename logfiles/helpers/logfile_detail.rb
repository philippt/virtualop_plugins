def logfile_detail(machine, params)
  log_file = machine.find_logs.select { |x| x["path"] == params["path"] }.first
  raise "no log file definition found for #{params["path"]} on #{machine.name}" unless log_file
  raise "no parser defined for log file #{params["path"]}" unless log_file.has_key?("parser") and log_file["parser"] != ""
  parser = @op.list_parsers.select { |x| x['name'] == log_file['parser'] }.first
  [ log_file, parser ]
end
  