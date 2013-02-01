# TODO would it be better to contribute to terminate?
contributes_to :notify_terminate_vm_start

execute do |params|
  data = {
    "name" => params["name"] + '.' + params["machine"],
    "user" => params["current_user"]
  }
  
  tempfile = @op.write_tempfile("data" => data.to_json())
  
  @op.with_machine("localhost") do |localhost|
    localhost.http_post("data_file" => tempfile.path, "target_url" => config_string("target_url") + '/vm_terminated')
  end
end
