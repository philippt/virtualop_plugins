description 'connects to a machine setup in hetzner default configuration and tries to assimilate it'

param :machine

on_machine do |machine, params|
  machine.yum_update
  
  own_public_keys = @op.list_public_keys("machine" => "localhost")
  own_public_keys.each do |key|
    machine.add_public_key("public_key" => key)
  end
  
  machine.ssh("command" => "sed -i -e 's/#PermitUserEnvironment no/PermitUserEnvironment yes/' /etc/ssh/sshd_config")
  machine.ssh("command" => "sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config")
  machine.restart_unix_service("name" => "sshd")
  
  machine.install_vm # to get the service descriptors
  
  machine.install_service("service_root" => "/etc/vop/service_descriptors/host")
end
