param :machine
param :keypair

on_machine do |machine, params|
  keypair = @op.list_stored_keypairs.select { |x| x["alias"] == params["keypair"] }.first
  @op.with_machine('localhost') do |localhost|
    public_key = localhost.read_file(keypair["public_key_file"])
    machine.add_authorized_key(public_key)
  end
  
  @op.without_cache do
    machine.list_authorized_keys
  end
end  
