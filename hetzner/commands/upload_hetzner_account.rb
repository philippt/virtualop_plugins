description "uploads hetzner configuration data from the local machine to the target machine"

param :machine
param :hetzner_account

on_machine do |machine, params|
  account = @op.list_hetzner_accounts.select { |x| x["alias"] == params["hetzner_account"] }.first
  
  cmd = 'add_hetzner_account'
  account.each do |k,v|
    cmd += " #{k}=#{v}"
  end
  
  machine.vop_call("command" => cmd)     
end
