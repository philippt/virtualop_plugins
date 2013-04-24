param :machine

param! "name", "the volume that should be deleted", 
  :lookup_method => lambda { |request| 
    @op.list_volumes("machine" => request.get_param_value("machine")).map { |x| x["name"] } 
  }

on_machine do |machine, params|
  machine.ssh("command" => "virsh vol-delete #{params["name"]} --pool default")
end
