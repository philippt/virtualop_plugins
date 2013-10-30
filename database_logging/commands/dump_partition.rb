description "copies the specified table into a tarballed dump in the archive directory"

param! "table_name", "the name of the table to be moved", 
  :default_param => true, 
  :allows_multiple_values => true

execute do |params|
  @op.with_machine('localhost') do |machine|
    params["table_name"].each do |table_name|    
      machine.dump_database(
        "database" => config_string("db_name"),
        "table_whitelist" => table_name,
        "target_filename" => archive_dir(machine) + "/" + table_name,
        "skip_check" => "true",
        "dont_drop" => "true"
      )
    end
  end
end