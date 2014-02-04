
execute do |params|
  identity = @op.whoareyou.split('@').last
  @op.with_machine(identity) do |me|
    me.restore_data()
    @op.configure_machines("identity" => identity)
    
    vop_webapp_path = me.service_details("service" => "virtualop_webapp/virtualop_webapp")["service_root"]
    me.rvm_ssh("cd #{vop_webapp_path} && rake db:migrate")
  end
end