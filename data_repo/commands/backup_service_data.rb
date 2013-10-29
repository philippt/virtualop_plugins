description "creates backups for all read-write databases and filesystems associated to the specified service"

param :machine
param :service
param "timestamp", "the timestamp to use for the backup names"

add_columns [ "type", "source", "backup_name" ]

on_machine do |machine, params|
  result = []
  
  timestamp_to_use = params.has_key?('timestamp') ? params['timestamp'] : Time.now().strftime("%Y%m%d%H%M")
  
  details = machine.service_details("service" => params["service"])
  
  details["databases"].each do |database|
    next if database["mode"] == "read-only"
    dump_name = "db_backup-" + [ machine.name.gsub('-', '_'), [ params["service"].gsub(/[-\/]/, '_'), database["name"] ].join("."), timestamp_to_use ].join('-')
    
    options = {
      "database" => database["name"],
      "dump_name" => dump_name
    }
    options["table_blacklist"] = database["exclude_tables"] if database.has_key? "exclude_tables"
    options["table_whitelist"] = database["include_tables"] if database.has_key? "include_tables"
    machine.dump_database(options)
    
    result << {
      "type" => "database",
      "source" => database["name"],
      "backup_name" => dump_name
    }
  end
  
  details["local_files"].each do |local_files|
    unless /^\//.match(local_files["path"])
      local_files["path"] = details["service_root"] + '/' + local_files["path"]
    end
    tarball_name = "file_backup-" + [ 
      machine.name.gsub('-', '_'), 
      [ params["service"].gsub(/[-\/]/, '_'), local_files["alias"] ].join("."), 
      timestamp_to_use 
    ].join('-')
    machine.tar(
      "working_dir" => local_files["path"],
      "files" => "*",
      "tar_name" => local_backup_dir(machine) + '/' + tarball_name + ".tgz"
    )
    result << {
      "type" => "directory",
      "source" => local_files["path"],
      "backup_name" => tarball_name
    }
  end
  
  @op.without_cache do
    machine.list_local_backups
  end
  
  result
end  