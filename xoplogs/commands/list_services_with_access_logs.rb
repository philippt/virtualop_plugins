description "returns services for which logs have been processed"

param :machine, "machine filter", :mandatory => false

add_columns [ :host_name, :service_name ]

mark_as_read_only

execute do |params|
  result = []
  
  url = @op.xoplogs_domain + '/aggregated/services_list'
  services = JSON.parse(@op.http_get("url" => url))
  
  services.each do |host_name, entries|
    entries.each do |type, lines|
      if params.has_key?('machine')
        next unless host_name == params['machine']
      end
      lines.each do |service_name|
        result << {
          'host_name' => host_name,
          'service_name' => service_name,
          'type' => type
        }
      end
    end
  end
  
  #result = params.has_key?('machine') ? services[params['machine']] : services.values
  
  if false
    @op.with_machine(config_string('xoplogs_machine')) do |xoplogs|
      begin
        # TODO hardcoded db name - move into xoplogs webapp
        result = mysql_xml_to_rhcp xoplogs.execute_sql("database" => "xoplogs_development", "statement" => "select distinct host_name, service_name from http_access_entry_tables", "xml" => true)
        if params.has_key?("machine")
          result = result.select do |candidate|
            candidate["host_name"] == params["machine"]
          end
        end
      rescue => detail
        $logger.warn "could not fetch access logs from xoplogs : #{detail.message}"
      end
    end
  end
  result
end

