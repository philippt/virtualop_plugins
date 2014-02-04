param! "partition_name", "the identifier of the partition to delete"
param "dont_drop"

execute do |params|
  table_names = @op.list_tables_for_partition(params)
  @op.dump_partition("table_name" => table_names)
    
  @op.with_machine("localhost") do |machine|    
    table_names.each do |table_name|
      machine.execute_sql(
        "database" => config_string("db_name"),
        "statement" => "DROP TABLE #{table_name}"
      )
    end
  end unless params["dont_drop"] == 'true'
  
  @op.without_cache do
    @op.show_tables("machine" => "localhost", "database" => config_string("db_name"))
    @op.list_archived_partitions
    @op.list_partitions
  end
end
