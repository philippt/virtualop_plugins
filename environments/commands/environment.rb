param :machine

on_machine do |machine, params|
  machine.ssh("command" => "echo $VOP_ENV").strip
end
