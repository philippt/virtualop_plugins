description "dumps the specified table into a tarball in the archive directory and deletes it from the database"

param! "table_name", "the name of the table to be moved", 
  :default_param => true, 
  :allows_multiple_values => true

execute do |params|
  raise "boo!"
  
  @op.dump_partition(params)
    
  @op.with_machine("localhost") do |machine|    
    params["table_name"].each do |table_name|
      machine.execute_sql(
        "database" => config_string("db_name"),
        "statement" => "DROP TABLE #{table_name}"
      )
    end
    
    @op.without_cache do
      machine.show_tables("database" => config_string("db_name"))
      @op.list_archived_partitions
      @op.list_partitions
    end
  end
end  