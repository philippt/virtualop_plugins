description "performs the base installation for a new machine"

param :machine
param "http_proxy", "if specified, the http proxy is used for the installation and configured on the new machine"

ignore_extra_params

on_machine do |machine, params|
  machine.install_rpm_package("name" => [ "git", "vim", "screen", "man", "rubygems" ])
    
  machine.ssh_and_check_result("command" => "gem update --system")
    
  machine.mkdir('dir_name' => @op.plugin_by_name('service_descriptors').config_string('service_config_dir'))
  
  # TODO persist this
  machine.ssh_and_check_result("command" => "setenforce Permissive")
  machine.ssh_and_check_result("command" => "restorecon -R -v /root/.ssh")
  
  machine.ssh_and_check_result("command" => "sed -i -e 's!#PermitUserEnvironment no!PermitUserEnvironment yes!' /etc/ssh/sshd_config")
  # TODO add public keys and deactivate password login
  machine.ssh_and_check_result("command" => "/etc/init.d/sshd restart")
  
  machine.write_own_centos_repo()
  process_local_template(:http_proxy, machine, "/etc/profile.d/http_proxy.sh", binding()) if params.has_key?('http_proxy')

  # TODO seems this is not invalidated through the flush_cache() call above - not quite sure why, though    
  @op.without_cache do
    machine.list_services
  end
end
