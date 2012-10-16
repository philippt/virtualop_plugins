def response_type_backup
  add_columns [ "name", "type", "date", "host", "service" ]
end

def local_backup_dir(machine)
  config_string('local_backup_dir', false) || machine.home + '/tmp'
end
