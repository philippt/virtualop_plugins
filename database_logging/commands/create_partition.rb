description "creates the tables for a new partition"

param! "partition_name", "the identifier for the partition (will be part of the table name)"

execute do |params|
  dbh = @plugin.state[:dbh]
  %w|command_executions command_execution_params ssh_logging text_logging|.each do |table_name|
    partitioned_table_name = table_name + "_" + params["partition_name"]
    
    create_statement = read_local_template(table_name.to_sym, binding())
    dbh.query(create_statement)
  end
end
