description "returns services for which access logs have been processes"

param :machine, "machine filter", :mandatory => false

add_columns [ :host_name, :service_name ]

execute do |params|
  result = []
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
  result
end

