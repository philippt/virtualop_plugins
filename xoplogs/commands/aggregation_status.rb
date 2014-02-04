param :machine

add_columns [ :needs_aggregation, :the_count ]

on_machine do |machine, params|
  # TODO hardcoded db name
  mysql_xml_to_rhcp machine.execute_sql("database" => "xoplogs_development", "statement" => "select count(1) as the_count, needs_aggregation from http_access_entry_tables group by needs_aggregation", "xml" => "true")
end
