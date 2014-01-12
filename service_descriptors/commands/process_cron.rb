contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key?("cron")
    script_path = machine.write_background_start_script("service" => service["full_name"])
    machine.add_crontab_entry("data" => read_local_template(:crontab, binding()))
  end 
end