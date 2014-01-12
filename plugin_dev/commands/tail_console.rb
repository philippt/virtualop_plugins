param :machine
param! "name", "the VM name to tail", :default_param => true

on_machine do |machine, params|
  result = machine.ssh_extended("dont_loop" => "true", "command" => "virsh console #{params["name"]}", "request_pty" => "true", 
    "on_data" => lambda { |c, data| puts data   },
    "on_stderr" => lambda { |c, data| puts data }
  )    
  result["connection"].loop
end
