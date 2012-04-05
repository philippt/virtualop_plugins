params_as :notify_vm_setup_start

param :current_user

contributes_to :notify_vm_setup_start

execute do |params|
  
  data = {
    "name" => params["machine_name"],
    "user" => params["current_user"]
  }
  
  tempfile = @op.write_tempfile("data" => data.to_json())
  
  @op.with_machine("localhost") do |localhost|
    localhost.http_post("data_file" => tempfile.path, "target_url" => config_string("target_url") + '/vm_setup_start')
  end
  
  []
end
