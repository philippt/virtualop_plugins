description "installs a development VM for a user"

param "user", "the user to prepare the machine for"

execute do |params|
  user = params["user"]
  full_name = @op.setup_vm_somewhere("vm_name" => "user_#{user}_dev", "canned_service" => "apache/apache")
  
  @op.with_machine(full_name) do |machine|
    machine.disable_ssh_key_check
    machine.upload_stored_keypair # TODO which one (or generate?)
  end
end
