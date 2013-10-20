description "imports all logfiles configured for this machine"

param :machine

on_machine do |machine, params|
  tmp_dir = ENV['HOME'] + '/tmp'
  local_tmp_dir = tmp_dir + '/logs'
  
  result = []
  @op.with_machine(config_string('xoplogs_machine')) do |xoplogs|
    machine.find_logs.each do |log|    
      file_name = log["path"].split("/").last
      machine.download_file("file_name" => log["path"], "local_dir" => local_tmp_dir)
      path_for_import = '/var/lib/mysql_import/' + file_name
      xoplogs.upload_file(
        "local_file" => local_tmp_dir + '/' + file_name, 
        "target_file" => path_for_import
      )
      service_root = xoplogs.service_details("service" => "xoplogs/xoplogs")["service_root"]
      
      if log["source"] == "apache"
        
        parser = case log["format"]
        when "vop"
          "xop_apache"
        when "combined"
          "apache"
        else
          nil
        end
        
        $logger.warn "no known parser for log file #{log["path"]}" if nil == parser
          
        xoplogs.ssh("command" => "cd #{service_root} && `which rails` runner app/scripts/import_access_log.rb #{path_for_import} #{parser} #{params["machine"]} #{log["service"]}")
        result << { "path" => file_name }
      elsif log.has_key? "parser"
        xoplogs.ssh("command" => "cd #{service_root} && `which rails` runner app/scripts/import_access_log.rb #{path_for_import} #{log["parser"]} #{params["machine"]} #{log["service"]}")
        result << { "path" => file_name }        
      end
    end
  end
  result
end
