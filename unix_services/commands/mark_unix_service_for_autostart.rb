description "modifies the system config so that the specified service is started automatically on system startup"

param :machine
param :unix_service, :default_param => true, :allows_multiple_values => true

as_root do |machine, params|
  names = params["name"]
  unless names.is_a? Array
    names = [ names ]
  end
  names.each do |name|
    machine.ssh "chkconfig #{name} on"
  end
end  
