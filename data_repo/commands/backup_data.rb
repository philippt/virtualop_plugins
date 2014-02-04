description "backups the data (both database and filesystem) of all services and uploads them into the data repository"

param :machine

add_columns [ "type", "source", "backup_name" ]

on_machine do |machine, params|
  # let's use one name for all backups
  the_timestamp = Time.now().strftime("%Y%m%d%H%M")
  
  # backup all services
  backup_items = []
  machine.list_services.each do |service|
    backup_items += machine.backup_service_data(
      "service" => service["full_name"],
      "timestamp" => the_timestamp
    )
  end
  
  # and upload everything that has been backuped
  backup_items.each do |backup_item|
    machine.upload_backup "local_backup" => backup_item["backup_name"]
  end
  
  backup_items
end