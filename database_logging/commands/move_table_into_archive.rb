description "dumps the specified table into a tarball in the archive directory and deletes it from the database"

param! "table_name", "the name of the table to be moved", :default_param => true, :allows_multiple_values => true

execute do |params|
    
  @op.with_machine("localhost") do |machine|    
    archive_dir = config_string("archive_directory", machine.home + "/db_archive")
    params["table_name"].each do |table_name|
      machine.dump_database(
        "database" => config_string("db_name"),
        "table_whitelist" => table_name,
        "target_filename" => archive_dir + "/" + table_name,
        "skip_check" => "true"
      )
      
      machine.execute_sql(
        "database" => config_string("db_name"),
        "statement" => "DROP TABLE #{table_name}"
      )
    end
    
    @op.without_cache do
      machine.show_tables("database" => config_string("db_name"))
    end
  end
end  