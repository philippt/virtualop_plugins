description "machine crawler - adds all known hosts and VMs to the list of known machines"

result_as :list_machines

execute do |params|
  result = []
    
  @op.find_hosts.each do |row|
    host_name = row["name"]
    begin
      @op.with_machine(host_name) do |host|
        result += host.find_unknown_vms
      end
    rescue => detail
      $logger.error("could not find unknown VMs on #{host_name} : #{detail.message}")
    end
  end
  
  if result.size > 0
    old_list = @op.list_known_machines
    write_known_machine_list(old_list + result)
  end
  
  result
end
