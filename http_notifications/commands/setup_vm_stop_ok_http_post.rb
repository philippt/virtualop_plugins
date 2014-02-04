contributes_to :notify_new_machine_stop_ok

param :current_user

accept_extra_params

execute do |params|
  pp params
  #machine_name = "#{params["extra_params"]["vm_name"]}.#{params["extra_params"]["machine"]}"
  machine_name = params["extra_params"]["result"]
  
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
    
    if params["extra_params"].has_key?('domain')
      payload["domain"] = params["extra_params"]["domain"]
    end
      
    {
      "name" => machine_name,
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