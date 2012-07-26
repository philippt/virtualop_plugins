description "creates backups for all read-write databases and filesystems associated to the specified service"

param :machine
param :service
param "timestamp", "the timestamp to use for the backup names"

add_columns [ "type", "source", "backup_name" ]

on_machine do |machine, params|
  result = []
  
  timestamp_to_use = params.has_key?('timestamp') ? params['timestamp'] : Time.now().strftime("%Y%m%d%H%M")
  
  # databases
  details = machine.service_details("service" => params["service"])
  databases = details["databases"]
  read_write_db_names = databases.select do |db|
    db["mode"] != "read-only"        
  end.map do |db|
    db["name"]
  end
  
  if read_write_db_names.size > 0 then
    dump_name = "db_backup_" + [ machine.name, params["service"], timestamp_to_use ].join('_')
    machine.dump_database(
      "database" => read_write_db_names,
      "dump_name" => dump_name
    )
    result << {
      "type" => "database",
      "source" => read_write_db_names.sort.join(','),
      "backup_name" => dump_name
    }
  end
  
  details["local_files"].each do |local_files|
    unless /^\//.match(local_files["path"])
      local_files["path"] = details["service_root"] + '/' + local_files["path"]
    end
    tarball_name = "file_backup_" + [ machine.name, [ params["service"], local_files["alias"] ].join("."), timestamp_to_use ].join('_')
    machine.tar(
      "working_dir" => local_files["path"],
      "files" => "*",
      "tar_name" => config_string('local_backup_dir') + '/' + tarball_name + ".tgz"
    )
    result << {
      "type" => "directory",
      "source" => local_files["path"],
      "backup_name" => tarball_name
    }
  end
  
  # TODO invalidate
  
  result
end  