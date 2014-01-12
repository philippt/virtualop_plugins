description "applies an activation key, registering packages and deploying configuration files"

param :spacewalk_host
param :machine
param :activation_key

on_machine do |machine, params|
  spacewalk_hostname = @op.spacewalk_connection_info["hostname"]
  machine.ssh("command" => "rhnreg_ks --serverUrl=http://#{spacewalk_hostname}/XMLRPC --activationkey=#{params["activation_key"]} --force")
  machine.yum_update
  
  @op.without_cache do
    @op.spacewalk_list_machines
  end
end

