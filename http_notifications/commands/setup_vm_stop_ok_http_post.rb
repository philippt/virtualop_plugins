params_as :notify_setup_vm_stop_ok

contributes_to :notify_setup_vm_stop_ok

execute do |params|
  machine_name = params["vm_name"] + '.' + params["machine"]
  
  data = @op.with_machine(machine_name) do |machine|  
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
      
    {
      "name" => machine.name,
      "status" => "ok",
      "errors" => [],
      "data" => payload
    }
  end
  
  tempfile = @op.write_tempfile("data" => data.to_json())
  
  @op.with_machine("localhost") do |localhost|
    localhost.http_post("data_file" => tempfile.path, "target_url" => config_string("target_url") + '/vm_created')
  end
 
  []
end
