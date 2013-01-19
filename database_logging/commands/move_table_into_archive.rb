description "dumps the specified table into a tarball in the archive directory and deletes it from the database"

param! "table_name", "the name of the table to be moved"

execute do |params|
    
  @op.with_machine("localhost") do |machine|
    archive_dir = config_string("archive_directory", machine.home + "/db_archive")
    machine.dump_database(
      "database" => config_string("db_name"),
      "table_whitelist" => params["table_name"],
      "target_filename" => archive_dir + "/" + params["table_name"],
      "skip_check" => "true"
    )
    
    machine.execute_sql(
      "database" => config_string("db_name"),
      "statement" => "DROP TABLE #{params["table_name"]}"
    )
    
    @op.without_cache do
      new_tables = machine.show_tables("database" => config_string("db_name"))
      candidates = new_tables.select do |table|
        table["name"] == params["table_name"]
      end
      raise "the table #{params["table_name"]} still seems to exist - something's wrong here." unless candidates.size == 0
    end
  end
end  