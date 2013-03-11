contributes_to :notify_new_machine_start

param :current_user

accept_extra_params

execute do |params|
  machine_name = "#{params["extra_params"]["vm_name"]}.#{params["extra_params"]["machine"]}"
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
