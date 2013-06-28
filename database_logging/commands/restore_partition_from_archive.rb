param! "partition_name", "the identifier for the partition", :allows_multiple_values => true

execute do |params|
  params["partition_name"].each do |partition_name|
    @op.with_machine("localhost") do |machine|    
      archive_dir = config_string("archive_directory", machine.home + "/db_archive")
      table_names().each do |fragment|
         
      end
      #machine.list_files("directory" => archive_dir).each do |file|
      #end
      
    end
  end
  
end
