description "establishes a connection to the libvirt system running on a virtualization host"

param :machine

on_machine do |machine, params|
  ssh_options = machine.ssh_options_for_machine
  
  target = (ssh_options.has_key?('user') ? (ssh_options['user'] + '@') : '') +
    ssh_options['host'] + ':' + ssh_options['port']

  #unless @connection_pool.has_key?(target_host)
  
  connection = nil
  begin
    Timeout::timeout(5) do
      $logger.info "opening libvirt connection to #{target}"
      connection = Libvirt::open("qemu+ssh://#{target}/system")
    end
  rescue Timeout::Error
    # Too slow!!
    $logger.warn("could not get a libvirt connection to '#{target}' within 5 secs")
  end

  raise "could not get a libvirt connection to '#{target}'" if connection == nil
  
  connection
end
