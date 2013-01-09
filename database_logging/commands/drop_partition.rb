description "drops all tables belonging to a partition"

param :machine
param! "partition_name", "the identifier of the partition to delete"

on_machine do |machine, params|
  dbh = @plugin.state[:dbh]
  %w|command_executions command_execution_params ssh_logging text_logging|.each do |table_name|
    partitioned_table_name = table_name + "_" + params["partition_name"]
    dbh.query("DROP TABLE #{partitioned_table_name}")
  end
end

