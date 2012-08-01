description "machine crawler - adds all known hosts and VMs to the list of known machines"

result_as :list_machines

execute do |params|
  result = []
  hosts = @op.find_hosts
  
  @op.flush_cache()
  
  hosts.each do |row|
    @op.with_machine(row["name"]) do |host|
      begin
        result += host.add_installed_vms_to_known_machines()
      rescue Exception => e
        $logger.warn("could not read installed vms from #{host.name} : #{e.message}")
      end
    end
  end
  
  @op.flush_cache()
  @op.list_machines
end
