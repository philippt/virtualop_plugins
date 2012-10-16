description "downloads the latest available backup for all services from the data repository and restores it, eliminating all local data."

param :machine
#param :mysql_host

add_columns [ "name", "type", "date", "host", "service" ]

on_machine do |machine, params|
  result = []
  machine.list_services.each do |service|
    p = params.clone()
    p["service"] = service["name"]
    result += @op.restore_service_data(p)
  end
  result
end
