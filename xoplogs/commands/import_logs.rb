description "imports all logfiles configured for this machine"

param :machine

add_columns [ :path, :status, :error_message ]

on_machine do |machine, params|
  tmp_dir = ENV['HOME'] + '/tmp'
  local_tmp_dir = tmp_dir + '/logs'
  
  result = []
  @op.with_machine(config_string('xoplogs_machine')) do |xoplogs|
    machine.find_logs.each do |log|    
      file_name = log["path"].split("/").last
      
      h = {
        "path" => file_name,
        "status" => "unknown",
        "error_message" => nil
      }
      
      begin
        machine.download_file("file_name" => log["path"], "local_dir" => local_tmp_dir)
        path_for_import = '/var/lib/mysql_import/' + file_name
        xoplogs.upload_file(
          "local_file" => local_tmp_dir + '/' + file_name, 
          "target_file" => path_for_import
        )
        service_root = xoplogs.service_details("service" => "xoplogs/xoplogs")["service_root"]
        
        service_name = log["service"].gsub('/', '_')          
        if log["source"] == "apache"
          
          parser = case log["format"]
          when "vop"
            "xop_apache"
          when "combined"
            "apache"
          end
          
          raise "no known parser for log file #{log["path"]}" unless parser
          xoplogs.ssh("command" => "cd #{service_root} && `which rails` runner app/scripts/import_access_log.rb #{path_for_import} #{parser} #{params["machine"]} #{service_name}")
          h["status"] = "ok"
        elsif log.has_key? "parser"
          script_name = (log.has_key?('format') && log['format'] == 'server_log') ? 'import_server_log' : 'import_access_log'         
          xoplogs.ssh("command" => "cd #{service_root} && `which rails` runner app/scripts/#{script_name}.rb #{path_for_import} #{log["parser"]} #{params["machine"]} #{service_name}")
          h["status"] = "ok"        
        end        
      rescue => detail
        h["status"] = "error"
        h["error_message"] = detail.message
      end
      result << h
    end
  end
  result
end
