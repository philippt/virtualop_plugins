param :machine
param :service

on_machine do |machine, params|
  machine.backup_service_data("service" => params["service"]).each do |backup|
    machine.upload_backup("local_backup" => backup["backup_name"], "service" => params["service"])
  end
end
