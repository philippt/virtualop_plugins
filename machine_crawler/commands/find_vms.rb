description "machine crawler - adds all known hosts and VMs to the list of known machines"

result_as :list_machines

execute do |params|
  result = []
  
  # @op.machines_in_tree.each do |machine|
    # unless @op.list_machines.map { |x| x["name"] }.include? machine.name
      # @op.add_known_machine(
        # "ssh_host" => machine.ipaddress, # 
        # "ssh_port" => vm["ssh_port"],
        # "ssh_password" => "the_password",
        # "ssh_user" => "root",
        # "name" => full_name,
        # "type" => "vm",
        # "host_name" => machine.name
      # )
    # end
  # end
  
  puts "STEP1: Hosts"
  #@op.flush_cache()
  hosts = @op.find_hosts
  #hosts = @op.list_machines.select { |x| x["type"] == 'host' }
  
  
  puts "STEP2: VMs on Hosts"
  @op.flush_cache()
  new_machines = []
  hosts.each do |row|
    host_name = row["name"]
    begin
      @op.with_machine(host_name) do |host|
        new_machines += host.find_unknown_vms
      end
    rescue => detail
      $logger.error("could not find for unknown VMs on #{host_name} : #{detail.message}")
    end
  end
  if new_machines.size > 0
    old_list = @op.list_known_machines
    write_known_machine_list(old_list + new_machines)
  end
  
  puts "STEP3: Machines"
  @op.flush_cache()
  @op.list_machines.each do |m|
    @op.with_machine(m["name"]) do |machine|
      machine.crawl_machine
    end
  end
end
