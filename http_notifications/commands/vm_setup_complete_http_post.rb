params_as :notify_vm_setup_complete

contributes_to :notify_vm_setup_complete

on_machine do |machine, params|
  ssh_options = {}
  machine.ssh_options_for_machine.select do |k,v|
    k != "password"
  end.each do |k,v|
    ssh_options[k] = v
  end
  payload = {
    "ip" => machine.ipaddress,
    "ssh" => ssh_options
  }
  
  if params["data"].has_key?('domain')
    payload["domain"] = params["data"]["domain"]
  end
    
  data = {
    "name" => machine.name,
    "status" => "ok",
    "errors" => [],
    "data" => payload
  }
  
  tempfile = @op.write_tempfile("data" => data.to_json())
  
  @op.with_machine("localhost") do |localhost|
    localhost.http_post("data_file" => tempfile.path, "target_url" => config_string("target_url") + '/vm_created')
  end
 
  []
end
