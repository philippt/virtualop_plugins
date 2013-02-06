param! "partition_name", "the identifier of the partition to delete"

execute do |params|
  table_names = @op.list_tables_for_partition(params)
  @op.move_table_into_archive("table_name" => table_names)
end
