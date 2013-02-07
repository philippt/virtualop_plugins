params_as :notify_setup_vm_start

param :current_user

contributes_to :notify_setup_vm_start

execute do |params|
  
  machine_name = params["vm_name"] + '.' + params["machine"]
  
  data = {
    "name" => machine_name,
    "user" => params["current_user"]
  }
  
  tempfile = @op.write_tempfile("data" => data.to_json())
  
  @op.with_machine("localhost") do |localhost|
    localhost.http_post("data_file" => tempfile.path, "target_url" => config_string("target_url") + '/vm_setup_start')
  end
  
  []
end
