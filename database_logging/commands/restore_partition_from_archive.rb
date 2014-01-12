param! "partition_name", "the identifier for the partition", :allows_multiple_values => true,
  :lookup_method => lambda { @op.list_archived_partitions }
  
add_columns [ :partition, :success, :failure ]

execute do |params|
  result = []
  params["partition_name"].each do |partition_name|
    @op.with_machine("localhost") do |machine|
      count_success = 0
      count_failure = 0
      table_names().each do |fragment|
        table_name = "#{fragment}_#{partition_name}"
        file_name = "#{archive_dir(machine)}/#{table_name}.tgz"
        if machine.file_exists file_name
          machine.restore_dump_from_file("file_name" => file_name, "dont_drop" => "true")
          count_success += 1          
        else
          $logger.warn "did not find dump file #{file_name} - weird."
          count_failure += 1 
        end         
      end
      result << {
        "partition" => partition_name,
        "success" => count_success,
        "failure" => count_failure 
      }
    end
  end
  result
end
