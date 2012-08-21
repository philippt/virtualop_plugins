description "machine crawler - adds all known hosts and VMs to the list of known machines"

result_as :list_machines

execute do |params|
  result = []
  
  puts "STEP1: Hosts"
  hosts = @op.find_hosts
  
  
  puts "STEP2: VMs on Hosts"
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
  
  puts "STEP3: Machines"
  @op.flush_cache()
  @op.list_machines.each do |m|
    @op.with_machine(m["name"]) do |machine|
      
    end
  end
end
