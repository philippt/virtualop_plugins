description 'restarts a unix service'

param :machine
param :unix_service, "foo", :default_param => true, :allows_multiple_values => true

as_root do |machine, params|
  params["name"].each do |name|
    machine.ssh "/etc/init.d/#{name} restart"
  end
end
